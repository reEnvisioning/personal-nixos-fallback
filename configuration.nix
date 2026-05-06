{pkgs, ...}: {
    imports = [
        # Generate with: nixos-generate-config --show-hardware-config > hardware-configuration.nix
        ./hardware-configuration.nix
        ./network.nix
    ];

    system.stateVersion = "25.11";

    networking.hostName = "headspace";

    services.greetd = {
        enable = true;
        settings = {
            default_session = {
                command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd start-hyprland";
                user = "greeter";
            };
        };
    };

    services.dunst.enable = true;

    hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
    };

    services.blueman.enable = true;

    users.users.visionary = {
        isNormalUser = true;
        extraGroups = [
            "wheel"
            "networkmanager"
        ];
    };

    nix.settings = {
        experimental-features = [
            "nix-command"
            "flakes"
        ];

        trusted-users = ["visionary"];
    };

    boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
    };

    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.kernelModules = [ "btusb" ];

    boot.initrd.luks.devices."luks-26fcc57f-6de2-4ea0-9c1e-9411b537d0ae".device = "/dev/disk/by-uuid/26fcc57f-6de2-4ea0-9c1e-9411b537d0ae";

    time.timeZone = "Europe/Berlin";

    # console keyboard layout
    console.keyMap = "us";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
        LC_ADDRESS = "de_DE.UTF-8";
        LC_IDENTIFICATION = "de_DE.UTF-8";
        LC_MEASUREMENT = "de_DE.UTF-8";
        LC_MONETARY = "de_DE.UTF-8";
        LC_NAME = "de_DE.UTF-8";
        LC_NUMERIC = "de_DE.UTF-8";
        LC_PAPER = "de_DE.UTF-8";
        LC_TELEPHONE = "de_DE.UTF-8";
        LC_TIME = "de_DE.UTF-8";
    };

    environment.systemPackages = with pkgs; [
        vim
        git
        firefox
        kitty
        nautilus
        hyprpaper
        hyprshot
        wl-clipboard
    ];
}
