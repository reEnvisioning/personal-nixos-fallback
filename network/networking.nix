{ config, pkgs, lib, hostname, ... }:
let
  cfg = config.networking.home;
  network = import ./network.nix;
in {
  options.networking.home.users = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "Users that get networking home-manager config applied";
  };

  imports = [
    ./firewall.nix
    ./dns.nix
    ./tailscale.nix
    ./opensnitch.nix
    ./proxy.nix
    ./tor.nix
  ];

  networking.hostName = hostname;

  networking.networkmanager.enable = network.networkmanager.enable;
  networking.networkmanager.dns = network.networkmanager.dns;
  networking.networkmanager.settings = network.networkmanager.settings;

  networking.nftables.enable = true;

  config = lib.mkIf (cfg.users != []) {
    home-manager.users = builtins.listToAttrs (map (username: {
      name = username;
      value.imports = [ ./hm.nix ];
    }) cfg.users);
  };
}
