{
  dns = {
    servers = [ "9.9.9.9" "149.112.112.112" "2620:fe::fe" "2620:fe::9" ];
    doT = true;
    domains = [ "~." ];
  };

  firewall = {
    localSendExtraRules = ''
      ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } tcp dport 53317 accept
      ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } udp dport 53317 accept
    '';
  };

  networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    settings = {
      main = {
        connection-check-interval = 0;
        "wifi.scan-rand-mac-address" = true;
      };
    };
  };
}
