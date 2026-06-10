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
        ${pkgs.iproute2}/bin/ip route add ${s.serverIp}/32 via ${s.gateway} 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip rule add fwmark 2 table 100 priority 100 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip route add default via ${s.gateway} table 100 2>/dev/null || true
        ${pkgs.iptables}/bin/iptables -t mangle -A OUTPUT -m cgroup --path "/system.slice/bypass-wg.slice" -j MARK --set-mark 2 2>/dev/null || true
        ${pkgs.nftables}/bin/nft add rule inet wg-killswitch output \
          ip daddr ${s.serverIp} udp dport ${toString s.serverPort} accept
        ${pkgs.nftables}/bin/nft add rule inet wg-killswitch output \
          oifname != "lo" oifname != "wg0" meta mark != 2 \
          counter reject with icmpx type admin-prohibited 2>/dev/null || true
      '';

      postShutdown = ''
        for pattern in "daddr ${s.serverIp}" "counter reject"; do
          handle=$(${pkgs.nftables}/bin/nft -a list chain inet wg-killswitch output 2>/dev/null \
            | ${pkgs.gnugrep}/bin/grep "$pattern" \
            | ${pkgs.gnugrep}/bin/grep -oP 'handle \K\d+')
          [ -n "$handle" ] && ${pkgs.nftables}/bin/nft delete rule inet wg-killswitch output handle $handle 2>/dev/null || true
        done
        ${pkgs.iptables}/bin/iptables -t mangle -D OUTPUT -m cgroup --path "/system.slice/bypass-wg.slice" -j MARK --set-mark 2 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip route del ${s.serverIp}/32 via ${s.gateway} 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip rule del fwmark 2 table 100 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip route del default via ${s.gateway} table 100 2>/dev/null || true
      '';
    };

    networking.nftables.ruleset = lib.mkAfter ''
      table inet wg-killswitch {
        chain output {
          type filter hook output priority -100; policy accept;
          oif "lo" accept
          ct state established,related accept
        }
      }
    '';

    boot.kernelModules = [ "xt_cgroup" ];

    systemd.slices.bypass-wg = {};

    security.sudo.extraRules = [{
      users = [ "visionary" ];
      commands = [{
        command = "${pkgs.systemd}/bin/systemd-run --slice=bypass-wg *";
        options = [ "NOPASSWD" "SETENV" ];
      }];
    }];

    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "vbox-bypass" ''
        exec sudo ${systemd}/bin/systemd-run --slice=bypass-wg --scope --property=KillMode=process --property=User=visionary \
          ${virtualbox}/bin/VirtualBox "$@"
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
