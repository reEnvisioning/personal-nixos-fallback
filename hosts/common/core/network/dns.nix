{ config, lib, ... }:
let
  network = import ./network.nix;
  isPrivateIPv4 = server:
    let
      parts = builtins.match "^([0-9]{1,3})\\.([0-9]{1,3})\\.([0-9]{1,3})\\.([0-9]{1,3})$" server;
      octets = if parts == null then [ ] else map lib.toInt parts;
    in
    parts != null
    && lib.all (octet: octet >= 0 && octet <= 255) octets
    && (builtins.elemAt octets 0 == 10
    || (builtins.elemAt octets 0 == 172 && builtins.elemAt octets 1 >= 16 && builtins.elemAt octets 1 <= 31)
    || (builtins.elemAt octets 0 == 192 && builtins.elemAt octets 1 == 168));
  plaintextServers = config.besein.dns.primaryPlaintextIPv4Servers;
  plaintextRules = lib.concatMapStringsSep "\n"
    (server: ''
      udp dport 53 ip daddr ${server} accept
      tcp dport 53 ip daddr ${server} accept
    '')
    plaintextServers;
in
{
  options.besein.dns.primaryPlaintextIPv4Servers = lib.mkOption {
    type = lib.types.listOf (lib.types.addCheck lib.types.str isPrivateIPv4);
    default = [ ];
    description = "Trusted IPv4 DNS servers that replace the encrypted public defaults.";
  };

  config = {
    services.resolved = {
      enable = true;
      settings.Resolve = {
        DNS = if plaintextServers == [ ] then network.dns.servers else plaintextServers;
        DNSOverTLS = if plaintextServers == [ ] then network.dns.doT else false;
        Domains = network.dns.domains;
      };
    };

    networking.nftables.ruleset = ''
      table inet dns-filter {
        chain output {
          type filter hook output priority filter + 1; policy accept;
          udp dport 53 ip daddr 127.0.0.0/8 accept
          udp dport 53 ip6 daddr ::1 accept
          tcp dport 53 ip daddr 127.0.0.0/8 accept
          tcp dport 53 ip6 daddr ::1 accept
          ${plaintextRules}
          udp dport 53 reject
          tcp dport 53 reject
        }
      }
    '';
  };
}
