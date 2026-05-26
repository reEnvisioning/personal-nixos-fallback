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
    # Cgroup rules are added dynamically by add-nftables-cgroup-rules.service
    # after all services and user sessions exist.
    table inet app-filter {
      chain output {
        type filter hook output priority filter; policy accept;

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

        # Check cgroup whitelist (populated dynamically)
        jump cgroup-check

        # No drop here — during boot the chain is empty and returns,
        # and policy accept ensures everything works.
        # After boot, the drop rule lives inside cgroup-check.
      }

      # Populated at runtime by add-nftables-cgroup-rules.service
      chain cgroup-check {
      }
    }
  '';

  # Dynamically add cgroup rules after all services and user sessions exist
  systemd.services.add-nftables-cgroup-rules = {
    description = "Add cgroup-based nftables whitelist rules";
    after = [ "nftables.service" "systemd-user-sessions.service" ];
    wants = [ "nftables.service" ];
    wantedBy = [ "nftables.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      PartOf = [ "nftables.service" ];
    };
    script = ''
      # Flush first so repeated runs (e.g. nftables restart) don't stack duplicates
      ${pkgs.nftables}/bin/nft flush chain inet app-filter cgroup-check

      ${pkgs.nftables}/bin/nft add rule inet app-filter cgroup-check \
        socket cgroupv2 level 2 "nix-daemon.service" accept
      ${pkgs.nftables}/bin/nft add rule inet app-filter cgroup-check \
        socket cgroupv2 level 2 "systemd-resolved.service" accept
      ${pkgs.nftables}/bin/nft add rule inet app-filter cgroup-check \
        socket cgroupv2 level 2 "NetworkManager.service" accept
      ${pkgs.nftables}/bin/nft add rule inet app-filter cgroup-check \
        socket cgroupv2 level 2 "sshd.service" accept
      ${pkgs.nftables}/bin/nft add rule inet app-filter cgroup-check \
        socket cgroupv2 level 2 "fail2ban.service" accept
      ${pkgs.nftables}/bin/nft add rule inet app-filter cgroup-check \
        socket cgroupv2 level 4 "allowed.slice" accept

      # Non-whitelisted apps fall through to this drop rule
      ${pkgs.nftables}/bin/nft add rule inet app-filter cgroup-check \
        log prefix "NFTABLES-DROP: " drop
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
