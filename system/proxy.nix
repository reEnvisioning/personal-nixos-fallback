{ config, pkgs, lib, ... }:

let
  secretResult = builtins.tryEval (import ../secret.nix);
  hasSecret = secretResult.success;
  inherit (pkgs) systemd;
  # Helper to send notifications from root systemd services to the user session
  notifyUser = "${pkgs.sudo}/bin/sudo -u visionary DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus WAYLAND_DISPLAY=wayland-1 DISPLAY=:0 ${pkgs.libnotify}/bin/notify-send -a Proxy";
in {
  config = lib.mkIf hasSecret (let
    s = secretResult.value;
  in {
    networking.wireguard.interfaces.wg0 = {
      ips = [ s.tunnelIp ];
      privateKey = s.clientPriv;
      allowedIPsAsRoutes = false;
      fwMark = "0xca6c";
      peers = [{
        publicKey = s.serverPub;
        presharedKey = s.wgPsk;
        allowedIPs = [ "0.0.0.0/0" "::/0" ];
        endpoint = "${s.serverIp}:${toString s.serverPort}";
        persistentKeepalive = 25;
      }];

      postSetup = ''
        ${pkgs.iproute2}/bin/ip route add ${s.serverIp}/32 via ${s.gateway} 2>/dev/null || true
        echo "pending" > /tmp/wg-vpn-status
      '';

      postShutdown = ''
        ${pkgs.nftables}/bin/nft flush chain inet wg-killswitch output 2>/dev/null || true
        ${pkgs.nftables}/bin/nft delete chain inet wg-killswitch output 2>/dev/null || true
        ${pkgs.nftables}/bin/nft delete table inet wg-killswitch 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip route del 0.0.0.0/1 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip route del 128.0.0.0/1 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip -6 route del ::/1 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip -6 route del 8000::/1 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip rule del fwmark 2 table 100 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip route del default via ${s.gateway} table 100 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip route del ${s.serverIp}/32 via ${s.gateway} 2>/dev/null || true
        echo "disconnected" > /tmp/wg-vpn-status
        ${notifyUser} "VPN disconnected" 2>/dev/null || true
      '';
    };

    systemd.services.wireguard-wg0 = {
      after = [ "nftables.service" ];
      wants = [ "nftables.service" ];
      serviceConfig = {
        TimeoutStartSec = 5;
        Restart = "on-failure";
        RestartSec = 10;
      };
    };

    systemd.services.wireguard-monitor = {
      description = "WireGuard connection monitor";
      after = [ "network.target" "nftables.service" ];
      wants = [ "nftables.service" ];
      serviceConfig.Type = "oneshot";
      script = ''
        if [ -f /tmp/wg-disabled ]; then
          exit 0
        fi

        if ! ${pkgs.wireguard-tools}/bin/wg show wg0 >/dev/null 2>&1; then
          exit 0
        fi
        HS=$(${pkgs.wireguard-tools}/bin/wg show wg0 latest-handshakes 2>/dev/null)
        TS=$(echo "$HS" | ${pkgs.gnugrep}/bin/grep -oP '\d+$')
        NOW=$(${pkgs.coreutils}/bin/date +%s)
        ROUTES=$(${pkgs.iproute2}/bin/ip route show 0.0.0.0/1 2>/dev/null | ${pkgs.gnugrep}/bin/grep -c "dev wg0" || true)

        if [ -n "$TS" ] && [ "$TS" != "0" ] && [ $((NOW - TS)) -lt 30 ]; then
          if [ "$ROUTES" -eq 0 ]; then
            ${pkgs.iproute2}/bin/ip route add 0.0.0.0/1 dev wg0 2>/dev/null || true
            ${pkgs.iproute2}/bin/ip route add 128.0.0.0/1 dev wg0 2>/dev/null || true
            ${pkgs.iproute2}/bin/ip -6 route add ::/1 dev wg0 2>/dev/null || true
            ${pkgs.iproute2}/bin/ip -6 route add 8000::/1 dev wg0 2>/dev/null || true

            ${pkgs.iproute2}/bin/ip rule add fwmark 2 table 100 priority 100 2>/dev/null || true
            ${pkgs.iproute2}/bin/ip route add default via ${s.gateway} table 100 2>/dev/null || true

            ${pkgs.nftables}/bin/nft add table inet wg-killswitch 2>/dev/null || true
            ${pkgs.nftables}/bin/nft add chain inet wg-killswitch output { type filter hook output priority filter + 2\; policy accept\; } 2>/dev/null || true
            ${pkgs.nftables}/bin/nft add rule inet wg-killswitch output \
              socket cgroupv2 level 2 "system.slice/bypass-wg.slice" meta mark set 2 2>/dev/null || true
            ${pkgs.nftables}/bin/nft add rule inet wg-killswitch output \
              ip daddr ${s.serverIp} udp dport ${toString s.serverPort} accept
            ${pkgs.nftables}/bin/nft add rule inet wg-killswitch output \
              oifname != "lo" oifname != "wg0" meta mark != 2 \
              counter reject with icmpx type admin-prohibited

            echo "connected" > /tmp/wg-vpn-status
            ${notifyUser} "VPN connected" 2>/dev/null || true
          fi
        else
          if [ "$ROUTES" -gt 0 ]; then
            ${pkgs.nftables}/bin/nft flush chain inet wg-killswitch output 2>/dev/null || true
            ${pkgs.iproute2}/bin/ip route del 0.0.0.0/1 2>/dev/null || true
            ${pkgs.iproute2}/bin/ip route del 128.0.0.0/1 2>/dev/null || true
            ${pkgs.iproute2}/bin/ip -6 route del ::/1 2>/dev/null || true
            ${pkgs.iproute2}/bin/ip -6 route del 8000::/1 2>/dev/null || true
            echo "unreachable" > /tmp/wg-vpn-status
            ${notifyUser} "VPN server unreachable — using direct connection" 2>/dev/null || true
          fi
        fi
      '';
    };

    systemd.timers.wireguard-monitor = {
      description = "Check WireGuard connection every 30s";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5s";
        OnUnitActiveSec = "30s";
      };
    };

    systemd.slices.bypass-wg = {
      wantedBy = [ "multi-user.target" ];
    };

    security.sudo.extraRules = [{
      users = [ "visionary" ];
      commands = [
        {
          command = "${systemd}/bin/systemd-run --slice=bypass-wg *";
          options = [ "NOPASSWD" "SETENV" ];
        }
      ];
    }];

    environment.systemPackages = with pkgs; [
      libnotify
      (writeShellScriptBin "vbox-bypass" ''
        exec sudo ${systemd}/bin/systemd-run --slice=bypass-wg --scope \
          --property=KillMode=process --property=User=visionary \
          ${virtualbox}/bin/VirtualBox "$@"
      '')
      (pkgs.runCommand "virtualbox-bypass-wrapper" {
        preferLocalBuild = true;
      } ''
        mkdir -p $out/bin
        cat > $out/bin/VirtualBox << 'WRAPPER'
        #!${pkgs.runtimeShell}
        exec ${systemd}/bin/systemd-run --slice=bypass-wg --scope \
          --property=KillMode=process --property=User=visionary \
          ${virtualbox}/bin/VirtualBox "$@"
        WRAPPER
        chmod +x $out/bin/VirtualBox
      '')
      (writeShellScriptBin "proxy-off" ''
        touch /tmp/wg-disabled
        notify-send -a "Proxy" "Proxy disabled"
        systemctl stop wireguard-wg0
      '')
      (writeShellScriptBin "proxy-on" ''
        rm -f /tmp/wg-disabled
        systemctl start wireguard-wg0
        notify-send -a "Proxy" "Proxy enabled"
      '')
    ];

    services.opensnitch.rules = {
      wireguard-daemon = {
        name = "wireguard-daemon";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "regexp";
          sensitive = false;
          operand = "process.path";
          data = "^/nix/store/.*/bin/wg$";
        };
      };
      virtualbox-bypass = {
        name = "virtualbox-bypass";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "regexp";
          sensitive = false;
          operand = "process.path";
          data = "^/nix/store/.*[Vv]irtual[Bb]ox";
        };
      };
      wireguard-kernel = {
        name = "wireguard-kernel";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          sensitive = false;
          operand = "dest.ip";
          data = s.serverIp;
        };
      };
    };
  });
}
