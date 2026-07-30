{
  description = "NixOS configuration for reEnvisioning";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    retheme = {
      url = "github:reEnvisioning/test-reTheme";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, disko, retheme, ... }:
    let
      hostname = "headspace";
      pc = "desktop";
      cpuVendor = "intel";
      gpuVendor = "nvidia";
      system = "x86_64-linux";
      gitUsername = "reEnvisioning";
      inputs = { inherit nixpkgs nixpkgs-unstable home-manager disko retheme; };
      unstable = import nixpkgs-unstable {
        inherit system;
      };

      usernames = [ "visionary" ];
      primaryUser = builtins.head usernames;
      allUsers = usernames;
      rethemePackage = retheme.packages.${system}.default;

      mkSystem = { pc }: inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs hostname unstable gitUsername pc cpuVendor gpuVendor rethemePackage; nixUsers = allUsers; trustedUsers = usernames; username = primaryUser; };
        modules = [
          ./system/default.nix
          {
            nixpkgs.overlays = [
              (final: prev: { inherit unstable; })
            ];
          }
          inputs.home-manager.nixosModules.home-manager
          ./theme/appearance.nix
          ({ pkgs, ... }: {
            networking.hostName = hostname;
            appearance.users = allUsers;

            users.users = builtins.listToAttrs (
              (map
                (u: {
                  name = u;
                  value = {
                    isNormalUser = true;
                    initialPassword = "changeme";
                    extraGroups = [ "wheel" "networkmanager" "disk" "vboxusers" ];
                  };
                })
                usernames)
            );

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = { inherit hostname unstable gitUsername pc cpuVendor gpuVendor rethemePackage; };

            home-manager.users = builtins.listToAttrs (
              (map
                (u: {
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
                })
                usernames)
            );
          })
        ];
      };
    in
    {
      nixosConfigurations.headspace = mkSystem { pc = "desktop"; };
      nixosConfigurations.usb = mkSystem { pc = "usb"; };

      apps.x86_64-linux.disko = {
        type = "app";
        program = "${inputs.disko.packages.x86_64-linux.disko}/bin/disko";
      };

      formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;

      devShells.x86_64-linux =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        {
          default = import ./devshells/default.nix { inherit pkgs; };
          python = import ./devshells/python.nix { inherit pkgs; };
          rust = import ./devshells/rust.nix { inherit pkgs; };
          web = import ./devshells/web.nix { inherit pkgs; };
        };

      checks.x86_64-linux = {
        build = self.nixosConfigurations.headspace.config.system.build.toplevel;
      };
    };
}
