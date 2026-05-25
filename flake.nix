{
  description = "NixOS configuration for headspace";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    hostname = "headspace";
    username = "visionary";
  in {
    nixosConfigurations.${hostname} = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs hostname username; };
      modules = [
        ./system/default.nix
        inputs.home-manager.nixosModules.home-manager
        ./theme/appearance.nix
        {
          appearance.users = [ username ];

          home-manager.extraSpecialArgs = { inherit hostname username; };

          home-manager.users.${username} = {
            imports = [
              (./. + "/home/${username}/home.nix")
              (./. + "/home/${username}/niri.nix")
              (./. + "/home/${username}/yazi.nix")
              (./. + "/home/${username}/firefox.nix")
              (./. + "/home/${username}/neovim.nix")
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
      build = inputs.self.nixosConfigurations.${hostname}.config.system.build.toplevel;
    };
  };
}
