{ ... }:
let
  network = import ./network.nix;
in {
  imports = [
    ./firewall.nix
    ./dns.nix
    ./tailscale.nix
  ];

  networking.networkmanager.enable = network.networkmanager.enable;
  networking.networkmanager.dns = network.networkmanager.dns;
  networking.networkmanager.settings = network.networkmanager.settings;
  networking.nftables.enable = true;
}
