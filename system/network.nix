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
      iptables -A OUTPUT -p udp --dport 53 -d 127.0.0.0/8 -j ACCEPT
      ip6tables -A OUTPUT -p udp --dport 53 -d ::1 -j ACCEPT
      iptables -A OUTPUT -p udp --dport 53 -j REJECT
      ip6tables -A OUTPUT -p udp --dport 53 -j REJECT
    '';
    firewall.extraStopCommands = ''
      iptables -D OUTPUT -p udp --dport 53 -d 127.0.0.0/8 -j ACCEPT 2>/dev/null || true
      ip6tables -D OUTPUT -p udp --dport 53 -d ::1 -j ACCEPT 2>/dev/null || true
      iptables -D OUTPUT -p udp --dport 53 -j REJECT 2>/dev/null || true
      ip6tables -D OUTPUT -p udp --dport 53 -j REJECT 2>/dev/null || true
    '';

    # Quad9 DNS configuration
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
