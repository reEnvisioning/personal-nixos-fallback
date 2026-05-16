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
                {
                    home-manager.users.visionary = {
                        imports = [
                            ./home/home.nix
                            ./home/hyprland.nix
                            ./home/yazi.nix
                            ./home/quickshell.nix
                            ./home/firefox.nix
                            ./home/neovim.nix
                        ];
                    };
                }
            ];
        };
    };
}
