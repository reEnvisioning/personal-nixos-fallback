{ config, pkgs, lib, ... }:

let
  cfg = config.services.tor.transparentProxy;

  gw4 = "10.200.1.1";
  ns4 = "10.200.1.2";
  prefix = "30";

  ipBin = "${pkgs.iproute2}/bin/ip";
  nftBin = "${pkgs.nftables}/bin/nft";

  netns-setup = pkgs.writeShellScript "tor-netns-setup" ''
    # Clean up stale state from previous failed runs
    ${ipBin} link delete veth-tor 2>/dev/null || true
    ${ipBin} netns delete tor-net 2>/dev/null || true

    # Create namespace
    ${ipBin} netns add tor-net

    # Create veth pair
    ${ipBin} link add veth-tor type veth peer name veth-tor-ns netns tor-net

    # Host side
    ${ipBin} addr add ${gw4}/${prefix} dev veth-tor
    ${ipBin} link set veth-tor up
    echo 1 > /proc/sys/net/ipv4/conf/veth-tor/route_localnet

    # Namespace side
    ${ipBin} netns exec tor-net ${ipBin} addr add ${ns4}/${prefix} dev veth-tor-ns
    ${ipBin} netns exec tor-net ${ipBin} link set veth-tor-ns up
    ${ipBin} netns exec tor-net ${ipBin} link set lo up
    ${ipBin} netns exec tor-net ${ipBin} route add default via ${gw4}

    # Disable IPv6 inside namespace (need sh -c so redirect happens inside the ns)
    ${ipBin} netns exec tor-net ${pkgs.runtimeShell} -c 'echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6'

    # DNS: ip netns exec auto-bind-mounts /etc/netns/<name>/resolv.conf
    mkdir -p /etc/netns/tor-net
    echo "nameserver ${gw4}" > /etc/netns/tor-net/resolv.conf

    # Kill-switch nftables inside namespace
    ${ipBin} netns exec tor-net ${nftBin} -f - << 'NFT'
table inet tor-filter {
    chain OUTPUT {
        type filter hook output priority filter; policy drop;
        oifname "lo" accept
        oifname "veth-tor-ns" accept
    }
}
NFT
  '';

  netns-teardown = pkgs.writeShellScript "tor-netns-teardown" ''
    ${ipBin} link delete veth-tor 2>/dev/null || true
    ${ipBin} netns delete tor-net 2>/dev/null || true
    rm -rf /etc/netns/tor-net 2>/dev/null || true
  '';

  torrc-validate = pkgs.writeShellScript "torrc-validate" ''
    ${config.services.tor.package}/bin/tor --verify-config
  '';
in {
  options.services.tor.transparentProxy = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable transparent Tor proxy namespace (torify / torshell)";
    };
  };

  config = lib.mkIf cfg.enable {
    services.tor = {
      enable = true;
      client.enable = true;
      settings = {
        TransPort = [{
          addr = "127.0.0.1";
          port = 9040;
          flags = [ "IsolateDestAddr" "IsolateDestPort" "IsolateClientProtocol" ];
        }];
        DNSPort = [{ addr = "127.0.0.1"; port = 5353; }];
        ControlPort = 9051;
        CookieAuthFileGroupReadable = true;
        VirtualAddrNetworkIPv4 = "10.192.0.0/10";
        AutomapHostsOnResolve = true;
      };
    };

    users.users.visionary.extraGroups = [ "tor" ];
    users.groups.tor = {};

    boot.kernel.sysctl."net.ipv4.conf.all.route_localnet" = 1;

    networking.firewall.allowedTCPPorts = [ 9040 ];
    networking.firewall.allowedUDPPorts = [ 5353 ];

    networking.nftables.ruleset = lib.mkAfter ''
      table inet tor-transparent {
        chain PREROUTING {
          type nat hook prerouting priority -100; policy accept;
          iifname "veth-tor" meta l4proto tcp dnat ip to 127.0.0.1:9040
          iifname "veth-tor" meta l4proto udp udp dport 53 dnat ip to 127.0.0.1:5353
        }
      }
    '';

    security.sudo.extraRules = [
      {
        groups = [ "tor" ];
        commands = [
          {
            command = "${pkgs.iproute2}/bin/ip netns exec tor-net *";
            options = [ "NOPASSWD" "SETENV" ];
          }
        ];
      }
    ];

    networking.networkmanager.unmanaged = lib.mkBefore [ "interface-name:veth-*" ];

    systemd.services.tor-netns = {
      description = "tor-net transparent proxy namespace";
      after = [ "tor.service" "network.target" "nftables.service" ];
      wants = [ "tor.service" "nftables.service" ];
      requiredBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${netns-setup}";
        ExecStop = "${netns-teardown}";
      };
    };

    systemd.services.tor = {
      postStart = "${torrc-validate}";
      reloadIfChanged = true;
    };

    services.opensnitch.rules.tor = {
      name = "tor";
      enabled = true;
      action = "allow";
      duration = "always";
      operator = {
        type = "regexp";
        sensitive = false;
        operand = "process.path";
        data = "^/nix/store/.*/bin/tor$";
      };
    };

    environment.systemPackages = with pkgs; [
      netcat-openbsd
      xxd
      (writeShellScriptBin "torify" ''
        target_user=$(logname 2>/dev/null || echo "''${SUDO_USER:-$USER}")
        if [ "$target_user" = "root" ]; then
          echo "torify: cannot determine your username" >&2
          exit 1
        fi
        exec sudo -n ${ipBin} netns exec tor-net ${pkgs.sudo}/bin/sudo -u "$target_user" -E -- "$@"
      '')
      (writeShellScriptBin "torshell" ''
        target_user=$(logname 2>/dev/null || echo "''${SUDO_USER:-$USER}")
        if [ "$target_user" = "root" ]; then
          echo "torshell: cannot determine your username" >&2
          exit 1
        fi
        exec sudo -n ${ipBin} netns exec tor-net su - "$target_user"
      '')
      (writeShellScriptBin "tor-newnym" ''
        cookie="/var/lib/tor/control_auth_cookie"
        if [ ! -r "$cookie" ]; then
          echo "tor-newnym: cannot read $cookie (are you in the 'tor' group?)" >&2
          exit 1
        fi
        raw=$(${pkgs.xxd}/bin/xxd -p "$cookie" | tr -d '\n')
        resp=$(printf "AUTHENTICATE %s\r\nSIGNAL NEWNYM\r\nQUIT\r\n" "$raw" \
          | ${pkgs.netcat-openbsd}/bin/nc -w2 127.0.0.1 9051 2>/dev/null)
        if echo "$resp" | ${pkgs.gnugrep}/bin/grep -q "250"; then
          echo "New Tor circuit established"
        else
          echo "tor-newnym: control port unreachable or auth failed" >&2
          exit 1
        fi
      '')
    ];
  };
}
