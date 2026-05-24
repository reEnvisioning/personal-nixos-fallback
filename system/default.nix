{pkgs, ...}: {
    imports = [
        ./hardware-configuration.nix
        ./network.nix
        ./desktop.nix
        ./plymouth.nix
        ./boot.nix
        ./greeter.nix
        ./bluetooth.nix
        ./audio.nix
        ./compositor.nix
        ./users.nix
        ./virtualisation.nix
        ./polkit.nix
        ./security.nix
        ./shell.nix
    ];

    system.stateVersion = "25.11";

    nix.settings = {
        experimental-features = [
            "nix-command"
            "flakes"
        ];

        allowed-users = ["visionary"];
        trusted-users = ["visionary"];
        auto-optimise-store = true;

    };

    nixpkgs.config.allowUnfree = true;

    nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
    };
    services.udisks2.enable = true;
    services.power-profiles-daemon.enable = true;

    environment.systemPackages = with pkgs; [
        vim
        git
        hyprshot
        pavucontrol
        brightnessctl
        temurin-bin-21
    ];

}
