{
  description = "NixOS configuration for headspace — by reEnvisioning";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: let
    hostname = "headspace";
    inputs = { inherit nixpkgs home-manager; };
  in {
    nixosConfigurations.${hostname} = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs hostname; nixUsers = [ "visionary" ]; };
      modules = [
        ./system/default.nix
        inputs.home-manager.nixosModules.home-manager
        ./theme/appearance.nix
        {
          appearance.users = [ "visionary" ];

          users.users.visionary = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" "vboxusers" "disk" ];
          };

          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.extraSpecialArgs = { inherit hostname; };

          home-manager.users.visionary = {
            _module.args = { username = "visionary"; };
            imports = [
              ./home/visionary/home.nix
              ./home/visionary/niri.nix
              ./home/visionary/yazi.nix
              ./home/visionary/firefox.nix
              ./home/visionary/librewolf.nix
              ./home/visionary/neovim.nix
            ];
          };
        }
      ];
    };

    formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

    devShells.x86_64-linux = {
      default = import ./devshells/default.nix { inherit inputs; };
      python  = import ./devshells/python.nix { inherit inputs; };
      rust    = import ./devshells/rust.nix { inherit inputs; };
      web     = import ./devshells/web.nix { inherit inputs; };
    };

    checks.x86_64-linux = {
      build = self.nixosConfigurations.${hostname}.config.system.build.toplevel;
    };
  };
}
