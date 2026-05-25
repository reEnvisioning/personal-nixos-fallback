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
    firewall.extraCommands = ''
      nft add table inet dns-filter
      nft add chain inet dns-filter output { type filter hook output priority filter + 1\; policy accept\; }
      nft add rule inet dns-filter output udp dport 53 ip daddr 127.0.0.0/8 accept
      nft add rule inet dns-filter output udp dport 53 ip6 daddr ::1 accept
      nft add rule inet dns-filter output udp dport 53 reject
      nft add rule inet dns-filter output tcp dport 53 ip daddr 127.0.0.0/8 accept
      nft add rule inet dns-filter output tcp dport 53 ip6 daddr ::1 accept
      nft add rule inet dns-filter output tcp dport 53 reject
    '';
    firewall.extraStopCommands = ''
      nft delete table inet dns-filter 2>/dev/null || true
    '';
  };

  networking.networkmanager.dns = "systemd-resolved";

  networking.networkmanager.settings.main = {
    connection-check-interval = 0;
    "wifi.scan-rand-mac-address" = true;
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
