{ config, pkgs, lib, ... }:

let
  secretResult = builtins.tryEval (import ../secret.nix);
  hasSecret = secretResult.success;
  inherit (pkgs) systemd;
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
        echo "disconnected" > /tmp/wg-last-state
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

    systemd.services.wireguard-monitor = {
      description = "WireGuard connection monitor";
      after = [ "network.target" "nftables.service" ];
      wants = [ "nftables.service" ];
      serviceConfig.Type = "oneshot";
      script = ''
        if [ -f /tmp/wg-offline ]; then
          exit 0
        fi

        if [ -f /tmp/wg-disabled ]; then
          exit 0
        fi

        # If wg0 doesn't exist, try to start it
        if ! ${pkgs.wireguard-tools}/bin/wg show wg0 >/dev/null 2>&1; then
          ${pkgs.systemd}/bin/systemctl start wireguard-wg0 2>/dev/null || true
          exit 0
        fi

        HS=$(${pkgs.wireguard-tools}/bin/wg show wg0 latest-handshakes 2>/dev/null)
        TS=$(echo "$HS" | ${pkgs.gnugrep}/bin/grep -oP '\d+$')
        NOW=$(${pkgs.coreutils}/bin/date +%s)
        ROUTES=$(${pkgs.iproute2}/bin/ip route show 0.0.0.0/1 2>/dev/null | ${pkgs.gnugrep}/bin/grep -c "dev wg0" || true)

        # Determine current state
        if [ -n "$TS" ] && [ "$TS" != "0" ] && [ $((NOW - TS)) -lt 30 ]; then
          CUR="connected"
        else
          CUR="pending"
        fi

        # Strike tracking: 3 consecutive failures → give up
        if [ "$CUR" = "connected" ]; then
          rm -f /tmp/wg-retry-count 2>/dev/null || true
        else
          RETRY=$(cat /tmp/wg-retry-count 2>/dev/null || echo 0)
          RETRY=$((RETRY + 1))
          echo "$RETRY" > /tmp/wg-retry-count
          if [ "$RETRY" -ge 3 ]; then
            touch /tmp/wg-offline
            ${pkgs.systemd}/bin/systemctl stop wireguard-wg0 2>/dev/null || true
            echo "offline" > /tmp/wg-vpn-status
            exit 0
          fi
        fi

        # Read previous state for transition detection
        LAST=$(cat /tmp/wg-last-state 2>/dev/null || echo "unknown")
        echo "$CUR" > /tmp/wg-last-state

        case "$CUR" in
          connected)
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
            fi
            ;;
        esac

        # Write current status
        echo "$CUR" > /tmp/wg-vpn-status
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
        rm -f /tmp/wg-disabled /tmp/wg-offline /tmp/wg-retry-count
        systemctl start wireguard-wg0
        HS=$(${pkgs.wireguard-tools}/bin/wg show wg0 latest-handshakes 2>/dev/null)
        TS=$(echo "$HS" | ${pkgs.gnugrep}/bin/grep -oP '\d+$')
        NOW=$(${pkgs.coreutils}/bin/date +%s)
        if [ -n "$TS" ] && [ "$TS" != "0" ] && [ $((NOW - TS)) -lt 10 ]; then
          notify-send -a "Proxy" "Proxy enabled"
        else
          notify-send -a "Proxy" -u critical "Proxy Offline" "Could not reach WireGuard server"
        fi
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
