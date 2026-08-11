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

    browserProfile = {
      url = "github:reEnvisioning/BrowserProfile";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plymouth = {
      url = "github:reEnvisioning/plymouth";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, disko, retheme, browserProfile, plymouth, stylix, sops-nix, ... }:
    let
      system = "x86_64-linux";
      inputs = { inherit nixpkgs nixpkgs-unstable home-manager disko retheme browserProfile plymouth stylix sops-nix; };
      unstable = import nixpkgs-unstable {
        inherit system;
      };

      usernames = [ "visionary" ];
      allUsers = usernames;
      rethemePackage = retheme.packages.${system}.default;
      browserProfilePackage = browserProfile.packages.${system}.default;

      mkSystem = { pc, hostname, cpuVendor, gpuVendor }: inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs hostname unstable pc cpuVendor gpuVendor rethemePackage browserProfilePackage; nixUsers = allUsers; trustedUsers = usernames; };
        modules = [
          ./hosts/common/core/system/default.nix
          {
            nixpkgs.overlays = [
              (final: prev: { inherit unstable; })
            ];
          }
          inputs.home-manager.nixosModules.home-manager
          inputs.stylix.nixosModules.stylix
          inputs.sops-nix.nixosModules.sops
          ./hosts/common/optional/theme/stylix.nix
          ./hosts/common/optional/theme/appearance.nix
          ({ pkgs, ... }: {
            networking.hostName = hostname;
            appearance.users = allUsers;
            programs.zsh.enable = true;

            users.users = builtins.listToAttrs (
              (map
                (u: {
                  name = u;
                  value = {
                    isNormalUser = true;
                    initialHashedPassword = "!";
                    shell = pkgs.zsh;
                    extraGroups = [ "wheel" "networkmanager" "disk" "vboxusers" ];
                  };
                })
                usernames)
            );

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = { inherit hostname unstable pc cpuVendor gpuVendor rethemePackage browserProfilePackage; };

            home-manager.users = builtins.listToAttrs (
              (map
                (u: {
                  name = u;
                  value = {
                    _module.args = { username = u; };
                    imports = [
                      ./home/${u}/default.nix
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
      nixosConfigurations.computer = mkSystem {
        pc = "computer";
        hostname = "headspace";
        cpuVendor = "intel";
        gpuVendor = "nvidia";
      };
      nixosConfigurations.laptop = mkSystem {
        pc = "laptop";
        hostname = "headspace";
        cpuVendor = "amd";
        gpuVendor = "amd";
      };
      nixosConfigurations.usb = mkSystem {
        pc = "usb";
        hostname = "blackspace";
        cpuVendor = "off";
        gpuVendor = "off";
      };

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
        build = self.nixosConfigurations.computer.config.system.build.toplevel;
      };
    };
}
