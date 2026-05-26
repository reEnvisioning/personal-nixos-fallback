{
  config,
  pkgs,
  lib,
  hostname,
  ...
}: {
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    firewall.enable = true;
    firewall.allowedTCPPorts = [ 53317 ];
    firewall.allowedUDPPorts = [ 53317 ];
  };

  networking.networkmanager.dns = "systemd-resolved";

  networking.networkmanager.settings.main = {
    connection-check-interval = 0;
    "wifi.scan-rand-mac-address" = true;
  };

  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    # Existing DNS filter — blocks direct DNS to non-localhost
    table inet dns-filter {
      chain output {
        type filter hook output priority filter + 1; policy accept;
        udp dport 53 ip daddr 127.0.0.0/8 accept
        udp dport 53 ip6 daddr ::1 accept
        udp dport 53 reject
        tcp dport 53 ip daddr 127.0.0.0/8 accept
        tcp dport 53 ip6 daddr ::1 accept
        tcp dport 53 reject
      }
    }

    # App-level firewall — default-deny for all outbound traffic
    # Cgroup directories are pre-created by precreate-nftables-cgroups.service
    # so nftables can validate them at rule-load time.
    table inet app-filter {
      chain output {
        type filter hook output priority filter; policy drop;

        # Allow loopback
        meta oif "lo" accept

        # Allow response packets for established connections
        ct state { established, related } accept

        # Allow DNS to local resolver (before cgroup check)
        udp dport 53 ip daddr 127.0.0.0/8 accept
        udp dport 53 ip6 daddr ::1 accept
        tcp dport 53 ip daddr 127.0.0.0/8 accept
        tcp dport 53 ip6 daddr ::1 accept

        # Allow ICMP (ping)
        icmp type { echo-request, echo-reply } accept
        icmpv6 type { echo-request, echo-reply } accept

        # ── Whitelist system services by cgroup level ──
        socket cgroupv2 level 2 "nix-daemon.service" accept
        socket cgroupv2 level 2 "systemd-resolved.service" accept
        socket cgroupv2 level 2 "NetworkManager.service" accept
        socket cgroupv2 level 2 "sshd.service" accept
        socket cgroupv2 level 2 "fail2ban.service" accept

        # ── Whitelist user apps launched in allowed.slice ──
        socket cgroupv2 level 4 "allowed.slice" accept

        # Log and drop everything else
        log prefix "NFTABLES-DROP: " drop
      }
    }
  '';

  # Pre-create cgroup directories so nftables can validate them at rule-load time
  systemd.services.precreate-nftables-cgroups = {
    description = "Pre-create cgroup directories for nftables";
    before = [ "nftables.service" ];
    wantedBy = [ "nftables.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /sys/fs/cgroup/system.slice/nix-daemon.service/
      mkdir -p /sys/fs/cgroup/system.slice/systemd-resolved.service/
      mkdir -p /sys/fs/cgroup/system.slice/NetworkManager.service/
      mkdir -p /sys/fs/cgroup/system.slice/sshd.service/
      mkdir -p /sys/fs/cgroup/system.slice/fail2ban.service/
      mkdir -p /sys/fs/cgroup/user.slice/user-1000.slice/user@1000.service/allowed.slice/
    '';
  };

  # Define the user-level systemd slice for network-allowed applications
  systemd.user.units."allowed.slice" = {
    text = ''
      [Slice]
      Description=Slice for network-allowed user applications
    '';
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.fail2ban.enable = true;

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = [ "9.9.9.9" "149.112.112.112" "2620:fe::fe" "2620:fe::9" ];
      DNSOverTLS = true;
      Domains = [ "~." ];
    };
  };

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];
}
