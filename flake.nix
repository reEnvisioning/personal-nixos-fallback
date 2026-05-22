{
    description = "NixOS configuration for headspace";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

        home-manager = {
            url = "github:nix-community/home-manager/master";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = inputs: {
        nixosConfigurations.headspace = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {inherit inputs;};
            modules = [
                ./system/default.nix
                inputs.home-manager.nixosModules.home-manager
                ./theme/appearance.nix
                {
                    visionary.theme.users = [ "visionary" ];

                    home-manager.users.visionary = {
                        imports = [
                            ./home/home.nix
                            ./home/hyprland.nix
                            ./home/yazi.nix
                            ./home/firefox.nix
                            ./home/neovim.nix
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
            build = inputs.self.nixosConfigurations.headspace.config.system.build.toplevel;
        };
    };
}
