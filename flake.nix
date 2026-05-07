{
    description = "NixOS configuration for headspace";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

        home-manager = {
            url = "github:nix-community/home-manager/master";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        elephant.url = "github:abenz1267/elephant";

        walker = {
            url = "github:abenz1267/walker";
            inputs.elephant.follows = "elephant";
        };
    };

    outputs = inputs: {
        nixosConfigurations.headspace = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {inherit inputs;};
            modules = [
                ./configuration.nix
                ./hyprland.nix
                inputs.home-manager.nixosModules.home-manager
                {
                    home-manager.users.visionary = {
                        imports = [
                            ./home.nix
                            inputs.walker.homeManagerModules.default
                        ];
                        programs.walker = {
                            enable = true;
                            runAsService = true;
                            elephant = {
                                providers = ["desktopapplications" "clipboard" "calc" "runner" "websearch"];
                            };
                        };
                    };
                }
            ];
        };
    };
}
