{ config, pkgs, lib, ... }:

let
  secretResult = builtins.tryEval (import ../secret.nix);
  hasSecret = secretResult.success;
in
{
  config = lib.mkIf hasSecret (let
    s = secretResult.value;
  in {
    networking.wireguard.interfaces.wg0 = {
      ips = [ s.tunnelIp ];
      privateKey = s.clientPriv;
      fwMark = "0xca6c";
      peers = [{
        publicKey = s.serverPub;
        presharedKey = s.wgPsk;
        allowedIPs = [ "0.0.0.0/0" "::/0" ];
        endpoint = "${s.serverIp}:${toString s.serverPort}";
        persistentKeepalive = 25;
      }];

      postSetup = ''
        echo "pending" > /tmp/wg-vpn-status
        (
          # Route to VPN server (relies on LAN, not on the server itself)
          ${pkgs.iproute2}/bin/ip route add ${s.serverIp}/32 via ${s.gateway} 2>/dev/null || true

          # Poll for a WireGuard handshake — up to 10 seconds
          for i in 1 2 3 4 5 6 7 8 9 10; do
            hs=$(${pkgs.wireguard-tools}/bin/wg show wg0 latest-handshakes 2>/dev/null)
            ts=$(echo "$hs" | ${pkgs.gnugrep}/bin/grep -oP '\d+$')
            now=$(${pkgs.coreutils}/bin/date +%s)
            if [ -n "$ts" ] && [ "$ts" != "0" ] && [ $((now - ts)) -lt 30 ]; then
              # Handshake confirmed — tunnel is up, enable kill switch
              ${pkgs.iproute2}/bin/ip rule add fwmark 2 table 100 priority 100 2>/dev/null || true
              ${pkgs.iproute2}/bin/ip route add default via ${s.gateway} table 100 2>/dev/null || true
              ${pkgs.nftables}/bin/nft add rule inet wg-killswitch output \
                socket cgroupv2 level 2 "system.slice/bypass-wg.slice" meta mark set 2 2>/dev/null || true
              ${pkgs.nftables}/bin/nft add rule inet wg-killswitch output \
                ip daddr ${s.serverIp} udp dport ${toString s.serverPort} accept
              ${pkgs.nftables}/bin/nft add rule inet wg-killswitch output \
                oifname != "lo" oifname != "wg0" meta mark != 2 \
                counter reject with icmpx type admin-prohibited
              echo "connected" > /tmp/wg-vpn-status
              sudo -u visionary \
                DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus" \
                ${pkgs.libnotify}/bin/notify-send -a "Proxy" "VPN connected" \
                2>/dev/null || true
              exit 0
            fi
            sleep 1
          done

          # No handshake — server unreachable, don't install kill switch
          echo "unreachable" > /tmp/wg-vpn-status
        ) &
      '';

      postShutdown = ''
        for pattern in "daddr ${s.serverIp}" "counter reject" "bypass-wg.slice"; do
          handle=$(${pkgs.nftables}/bin/nft -a list chain inet wg-killswitch output 2>/dev/null \
            | ${pkgs.gnugrep}/bin/grep "$pattern" \
            | ${pkgs.gnugrep}/bin/grep -oP 'handle \K\d+')
          [ -n "$handle" ] && ${pkgs.nftables}/bin/nft delete rule inet wg-killswitch output handle $handle 2>/dev/null || true
        done
        ${pkgs.iproute2}/bin/ip route del ${s.serverIp}/32 via ${s.gateway} 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip rule del fwmark 2 table 100 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip route del default via ${s.gateway} table 100 2>/dev/null || true
      '';
    };

    systemd.services.wireguard-wg0 = {
      after = [ "nftables.service" ];
      wants = [ "nftables.service" ];
    };

    systemd.services.wireguard-retry = {
      description = "Retry WireGuard connection if VPN route is missing";
      after = [ "network.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        if [ ! -f /tmp/wg-disabled ] && \
           ! ${pkgs.iproute2}/bin/ip route show ${s.serverIp} >/dev/null 2>&1; then
          ${pkgs.systemd}/bin/systemctl restart wireguard-wg0
        fi
      '';
    };

    systemd.timers.wireguard-retry = {
      description = "Retry WireGuard connection every 60s";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "30s";
        OnUnitActiveSec = "60s";
      };
    };

    systemd.slices.bypass-wg = {
      wantedBy = [ "multi-user.target" ];
    };

    security.sudo.extraRules = [{
      users = [ "visionary" ];
      commands = [
        {
          command = "${pkgs.systemd}/bin/systemd-run --slice=bypass-wg *";
          options = [ "NOPASSWD" "SETENV" ];
        }
        {
          command = "${pkgs.systemd}/bin/systemctl stop wireguard-wg0";
          options = [ "NOPASSWD" "SETENV" ];
        }
        {
          command = "${pkgs.systemd}/bin/systemctl start wireguard-wg0";
          options = [ "NOPASSWD" "SETENV" ];
        }
      ];
    }];

    environment.systemPackages = with pkgs; [
      libnotify
      (writeShellScriptBin "vbox-bypass" ''
        exec sudo ${systemd}/bin/systemd-run --slice=bypass-wg --scope --property=KillMode=process --property=User=visionary \
          ${virtualbox}/bin/VirtualBox "$@"
      '')
      (writeShellScriptBin "proxy-off" ''
        touch /tmp/wg-disabled
        notify-send -a "Proxy" "Proxy disabled"
        sudo systemctl stop wireguard-wg0
      '')
      (writeShellScriptBin "proxy-on" ''
        rm -f /tmp/wg-disabled
        sudo systemctl start wireguard-wg0
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
