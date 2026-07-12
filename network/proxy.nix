{ config, pkgs, lib, username, ... }:

let
  network = import ./network.nix;
  srv = network.secrets.default;
  inherit (pkgs) systemd;
  stateDir = "/run/wireguard-monitor";
  keyDir = "/etc/wireguard";

  isDirect = srv.type == "direct";
  isTailscale = srv.type == "tailscale";
  isTor = srv.type == "tor";
  hasServerIp = isDirect || isTailscale;
  serverIpOrNull = if hasServerIp then srv.serverIp else null;
  endpoint = if isTor then "127.0.0.1:${toString srv.localBridgePort}" else "${srv.serverIp}:${toString srv.serverPort}";

  socat-bridge = pkgs.writeShellScript "socat-wg-bridge" ''
    set -euo pipefail
    ONION="${srv.onionAddress}"
    ONION_PORT="${toString srv.onionPort}"
    SOCKS_PORT="${toString srv.torSocksPort}"
    BRIDGE_PORT="${toString srv.localBridgePort}"

    exec ${pkgs.socat}/bin/socat UDP4-LISTEN:"$BRIDGE_PORT",fork,reuseaddr \
      "EXEC:${pkgs.socat}/bin/socat STDIO SOCKS4A:127.0.0.1:$ONION:$ONION_PORT,socksport=$SOCKS_PORT",nofork
  '';

  proxy-off = pkgs.writeShellScriptBin "proxy-off" ''
    if [ -z "$SUDO_USER" ]; then
      echo "error: proxy-off must be run with sudo" >&2
      exit 1
    fi
    notifyUser() {
      sudo -u "$SUDO_USER" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u "$SUDO_USER")/bus" \
        "$@"
    }
    mkdir -p ${stateDir}
    touch ${stateDir}/wg-disabled
    rm -f ${stateDir}/wg-offline ${stateDir}/wg-retry-count 2>/dev/null || true
    notifyUser notify-send -a "Proxy Control" --expire-time=4000 "Proxy disabled"
    ${pkgs.nftables}/bin/nft flush chain inet wg-killswitch output 2>/dev/null || true
    ${pkgs.nftables}/bin/nft delete chain inet wg-killswitch output 2>/dev/null || true
    ${pkgs.nftables}/bin/nft delete table inet wg-killswitch 2>/dev/null || true
    systemctl stop wireguard-wg0
  '';

  proxy-on = pkgs.writeShellScriptBin "proxy-on" ''
    if [ -z "$SUDO_USER" ]; then
      echo "error: proxy-on must be run with sudo" >&2
      exit 1
    fi
    notifyUser() {
      sudo -u "$SUDO_USER" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u "$SUDO_USER")/bus" \
        "$@"
    }
    rm -f ${stateDir}/wg-disabled
    systemctl start wireguard-wg0
    for i in $(seq 1 10); do
      HS=$(${pkgs.wireguard-tools}/bin/wg show wg0 latest-handshakes 2>/dev/null)
      TS=$(echo "$HS" | ${pkgs.gnugrep}/bin/grep -oP '\d+$')
      NOW=$(${pkgs.coreutils}/bin/date +%s)
      if [ -n "$TS" ] && [ "$TS" != "0" ] && [ $((NOW - TS)) -lt 15 ]; then
        notifyUser notify-send -a "Proxy Control" --expire-time=4000 "Proxy enabled"
        exit 0
      fi
      sleep 1
    done
    notifyUser notify-send -a "Proxy" --expire-time=86400000 -u critical "Proxy Offline" "Could not reach WireGuard server"
  '';
in {
    networking.wireguard.interfaces.wg0 = {
      ips = [ srv.tunnelIp ];
      privateKeyFile = "${keyDir}/private.key";
      allowedIPsAsRoutes = false;
      fwMark = "0xca6c";
      peers = [{
        publicKey = srv.serverPub;
        presharedKeyFile = "${keyDir}/psk.key";
        allowedIPs = [ "0.0.0.0/0" "::/0" ];
        endpoint = "${endpoint}";
        persistentKeepalive = 25;
      }];

      postSetup = (lib.optionalString hasServerIp ''
        ${pkgs.iproute2}/bin/ip route add ${serverIpOrNull}/32 via ${srv.gateway} 2>/dev/null || true
      '') + (lib.optionalString isTor ''
        ${pkgs.systemd}/bin/systemctl start socat-wg-bridge 2>/dev/null || true
      '') + ''
        echo "pending" > ${stateDir}/wg-vpn-status
      '';

      postShutdown = ''
        ${pkgs.iproute2}/bin/ip route del 0.0.0.0/1 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip route del 128.0.0.0/1 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip -6 route del ::/1 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip -6 route del 8000::/1 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip rule del fwmark 2 table 100 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip route del default via ${srv.gateway} table 100 2>/dev/null || true
      '' + (lib.optionalString hasServerIp ''
        ${pkgs.iproute2}/bin/ip route del ${serverIpOrNull}/32 via ${srv.gateway} 2>/dev/null || true
      '') + (lib.optionalString isTor ''
        ${pkgs.systemd}/bin/systemctl stop socat-wg-bridge 2>/dev/null || true
      '') + ''
        echo "disconnected" > ${stateDir}/wg-vpn-status
        echo "disconnected" > ${stateDir}/wg-last-state
      '';
    };

    systemd.services.wireguard-wg0 = {
      wantedBy = lib.mkForce [ ];
      after = [ "nftables.service" ];
      wants = [ "nftables.service" ];
      serviceConfig = {
        TimeoutStartSec = 5;
        Restart = "no";
      };
    };

    systemd.targets.wireguard-wg0.wantedBy = lib.mkForce [ ];

    systemd.services.socat-wg-bridge = lib.mkIf isTor {
      description = "WireGuard over Tor socat bridge";
      after = [ "network.target" ];
      requires = [ "tor.service" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${socat-bridge}";
        Restart = "on-failure";
        RestartSec = 5;
      };
      wantedBy = lib.mkForce [ ];
    };

    systemd.services.wireguard-monitor = {
      description = "WireGuard connection monitor";
      after = [ "network.target" "nftables.service" ];
      wants = [ "nftables.service" ];
      serviceConfig.Type = "oneshot";
      script = ''
        stateDir="${stateDir}"
        serverIp="${if hasServerIp then serverIpOrNull else ""}"
        gateway="${srv.gateway}"

        mkdir -p "$stateDir"
        chmod 0755 "$stateDir"

        if [ -f "$stateDir"/wg-disabled ]; then
          exit 0
        fi

        ${lib.optionalString hasServerIp ''
        PING_OK=0
        ${pkgs.iputils}/bin/ping -c 1 -W 1 "$serverIp" >/dev/null 2>&1 || PING_OK=$?

        if [ "$PING_OK" -ne 0 ]; then
          if [ ! -f "$stateDir"/wg-offline ]; then
            rm -f "$stateDir"/wg-retry-count 2>/dev/null || true
            ${pkgs.systemd}/bin/systemctl stop wireguard-wg0 2>/dev/null || true
            touch "$stateDir"/wg-offline
            echo "offline" > "$stateDir"/wg-vpn-status
          fi
          exit 0
        fi

        if [ -f "$stateDir"/wg-offline ]; then
          rm -f "$stateDir"/wg-offline "$stateDir"/wg-retry-count 2>/dev/null || true
        fi
        ''}

        if ! ${pkgs.wireguard-tools}/bin/wg show wg0 >/dev/null 2>&1; then
          ${pkgs.systemd}/bin/systemctl start wireguard-wg0 2>/dev/null || true
          echo "pending" > "$stateDir"/wg-vpn-status
          exit 0
        fi

        HS=$(${pkgs.wireguard-tools}/bin/wg show wg0 latest-handshakes 2>/dev/null)
        TS=$(echo "$HS" | ${pkgs.gnugrep}/bin/grep -oP '\d+$')
        NOW=$(${pkgs.coreutils}/bin/date +%s)
        ROUTES=$(${pkgs.iproute2}/bin/ip route show 0.0.0.0/1 2>/dev/null | ${pkgs.gnugrep}/bin/grep -c "dev wg0" || true)

        if [ -n "$TS" ] && [ "$TS" != "0" ] && [ $((NOW - TS)) -lt 30 ]; then
          CUR="connected"
        else
          CUR="pending"
        fi

        if [ "$CUR" = "connected" ]; then
          rm -f "$stateDir"/wg-retry-count 2>/dev/null || true
        else
          rm -f "$stateDir"/wg-retry-count 2>/dev/null || true
          if [ ! -f "$stateDir"/wg-offline ]; then
            ${pkgs.systemd}/bin/systemctl stop wireguard-wg0 2>/dev/null || true
            touch "$stateDir"/wg-offline
            echo "offline" > "$stateDir"/wg-vpn-status
          fi
          exit 0
        fi

        LAST=$(cat "$stateDir"/wg-last-state 2>/dev/null || echo "unknown")
        echo "$CUR" > "$stateDir"/wg-last-state

        case "$CUR" in
          connected)
            if [ "$ROUTES" -eq 0 ]; then
              ${pkgs.iproute2}/bin/ip route add 0.0.0.0/1 dev wg0 2>/dev/null || true
              ${pkgs.iproute2}/bin/ip route add 128.0.0.0/1 dev wg0 2>/dev/null || true
              ${pkgs.iproute2}/bin/ip -6 route add ::/1 dev wg0 2>/dev/null || true
              ${pkgs.iproute2}/bin/ip -6 route add 8000::/1 dev wg0 2>/dev/null || true

              ${pkgs.iproute2}/bin/ip rule add fwmark 2 table 100 priority 100 2>/dev/null || true
              ${pkgs.iproute2}/bin/ip route add default via "$gateway" table 100 2>/dev/null || true

              ${pkgs.nftables}/bin/nft add table inet wg-killswitch 2>/dev/null || true
              ${pkgs.nftables}/bin/nft add chain inet wg-killswitch output { type filter hook output priority filter + 2\; policy accept\; } 2>/dev/null || true
              ${pkgs.nftables}/bin/nft add rule inet wg-killswitch output \
                socket cgroupv2 level 2 "system.slice/bypass-wg.slice" meta mark set 2 2>/dev/null || true

              ${lib.optionalString hasServerIp ''
              ${pkgs.nftables}/bin/nft add rule inet wg-killswitch output \
                ip daddr "$serverIp" udp dport "${toString srv.serverPort}" accept
              ${pkgs.nftables}/bin/nft add rule inet wg-killswitch output \
                ip daddr "$serverIp" icmp type echo-request accept
              ''}

              ${lib.optionalString isTor ''
              ${pkgs.nftables}/bin/nft add rule inet wg-killswitch output \
                oifname "lo" ip daddr 127.0.0.1 udp dport "${toString srv.localBridgePort}" accept
              ${pkgs.nftables}/bin/nft add rule inet wg-killswitch output \
                ip daddr 127.0.0.1 tcp dport "${toString srv.torSocksPort}" accept
              ''}

              ${pkgs.nftables}/bin/nft add rule inet wg-killswitch output \
                oifname != "lo" oifname != "wg0" meta mark != 2 \
                counter reject with icmpx type admin-prohibited
            fi
            ;;
        esac

        echo "$CUR" > "$stateDir"/wg-vpn-status
      '';
    };

    systemd.timers.wireguard-monitor = {
      description = "Check WireGuard connection every 5s";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1s";
        OnUnitActiveSec = "5s";
      };
    };

    system.activationScripts.wireguard-keys = ''
      install -d -m 0700 /resources/wireguard
      install -d -m 0700 /etc/wireguard
      chmod 0600 /resources/wireguard/private.key /resources/wireguard/psk.key 2>/dev/null || true
      for f in private.key psk.key; do
        src="/resources/wireguard/$f"
        dst="/etc/wireguard/$f"
        if [ -f "$src" ]; then
          cp "$src" "$dst"
          chmod 0600 "$dst"
        fi
      done
    '';

    systemd.slices.bypass-wg = {
      wantedBy = [ "multi-user.target" ];
    };

    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" &&
            subject.user == "${username}") {
          var unit = action.lookup("unit");
          if (unit && unit.startsWith("run-") && (unit.endsWith(".scope") || unit.endsWith(".service"))) {
            return polkit.Result.YES;
          }
        }
      });
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" &&
            action.lookup("unit") == "wireguard-wg0.service" &&
            subject.user == "${username}") {
          return polkit.Result.YES;
        }
      });
    '';

    environment.systemPackages = with pkgs; [
      wireguard-tools
      proxy-off
      proxy-on
    ] ++ lib.optionals isTor [ socat ];
}
