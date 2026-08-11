{ ... }:
let
  network = import ./network.nix;
in
{
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = network.dns.servers;
      DNSOverTLS = network.dns.doT;
      Domains = network.dns.domains;
    };
  };

  networking.nftables.ruleset = ''
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
  '';
}
