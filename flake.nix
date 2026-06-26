{
  description = "NixOS configuration for reEnvisioning";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }: let
    hostname = "headspace";
    system = "x86_64-linux";
    inputs = { inherit nixpkgs nixpkgs-unstable home-manager; };
    unstable = import nixpkgs-unstable {
      inherit system;
    };

    usernames = [ "visionary" ];
    primaryUser = builtins.head usernames;
  in {
    nixosConfigurations.${hostname} = inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs hostname unstable; nixUsers = usernames; username = primaryUser; };
      modules = [
        ./system/default.nix
        {
          nixpkgs.overlays = [
            (final: prev: { inherit unstable; })
          ];
        }
        inputs.home-manager.nixosModules.home-manager
        ./theme/appearance.nix
        {
          networking.hostName = hostname;
          appearance.users = usernames;

          users.users = builtins.listToAttrs (map (u: {
            name = u;
            value = {
              isNormalUser = true;
              initialPassword = "changeme";
              extraGroups = [ "wheel" "networkmanager" "disk" "vboxusers" ];
            };
          }) usernames);

          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.extraSpecialArgs = { inherit hostname unstable; };

          home-manager.users = builtins.listToAttrs (map (u: {
            name = u;
            value = {
              _module.args = { username = u; };
              imports = [
                ./home/${u}/home.nix
                ./home/${u}/niri.nix
                ./home/${u}/yazi.nix
                ./home/${u}/firefox.nix
                ./home/${u}/librewolf.nix
                ./home/${u}/ssh.nix
                ./home/${u}/neovim.nix
                ./network/hm.nix
              ];
            };
          }) usernames);
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
