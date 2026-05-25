{
  config,
  pkgs,
  lib,
  ...
}: {
  networking = {
    hostName = "headspace";
    networkmanager.enable = true;
    firewall.enable = true;
    firewall.allowedTCPPorts = [ 53317 ];
    firewall.allowedUDPPorts = [ 53317 ];
    firewall.extraCommands = ''
      iptables -A OUTPUT -p udp --dport 53 -d 127.0.0.0/8 -j ACCEPT
      ip6tables -A OUTPUT -p udp --dport 53 -d ::1 -j ACCEPT
      iptables -A OUTPUT -p udp --dport 53 -j REJECT
      ip6tables -A OUTPUT -p udp --dport 53 -j REJECT
    '';

    # Quad9 DNS configuration
  };

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
      DNS = [ "9.9.9.9" "149.112.112.112" ];
      DNSOverTLS = true;
      Domains = [ "~." ];
    };
  };

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  # Tell NetworkManager to use systemd-resolved
  environment.etc."NetworkManager/conf.d/dns.conf".text = ''
    [device]
    dns=systemd-resolved
  '';
}
