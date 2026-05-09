{pkgs, ...}:
let theme = import ./theme.nix;
in {
    imports = [
        ./hardware-configuration.nix
        ./network.nix
        ./desktop.nix
    ];

    programs.hyprland = {
        package = pkgs.hyprland;
        enable = true;
        xwayland.enable = true;
    };

    xdg.portal = {
        enable = true;
        extraPortals = [
            pkgs.xdg-desktop-portal-gtk
            pkgs.xdg-desktop-portal-hyprland
        ];
    };

    system.stateVersion = "25.11";

    # Enable unfree software (required for NVIDIA proprietary drivers)
    nixpkgs.config.allowUnfree = true;

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

    # Audio
    security.rtkit.enable = true;

    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
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
        hyprpaper
        hyprshot
        wl-clipboard
        pavucontrol
        qt5.qtwayland
        qt6.qtwayland
        libnotify
    ];

    environment.variables = {
        "QT_QPA_PLATFORM" = "wayland;xcb";
        "ADW_DISABLE_PORTAL" = "1";
        "QT_STYLE_OVERRIDE" = "adwaita-dark";
        "XDG_CURRENT_DESKTOP" = "Hyprland";
    };

}
