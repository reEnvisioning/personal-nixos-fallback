{pkgs, ...}:
let theme = import ./theme.nix;
in {
    imports = [
        # Generate with: nixos-generate-config --show-hardware-config > hardware-configuration.nix
        ./hardware-configuration.nix
        ./network.nix
        ./desktop.nix
    ];

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

        extra-substituters = ["https://walker.cachix.org" "https://walker-git.cachix.org"];
        extra-trusted-public-keys = [
            "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
            "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
        ];
    };

    # Audio: PipeWire stack (Omarchy-style)
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
        firefox
        kitty
        hyprpaper
        hyprshot
        wl-clipboard
        pavucontrol
        qt5.qtwayland
        qt6.qtwayland
    ];

    environment.variables = {
        "GTK_THEME" = "Adwaita-dark";
        "QT_QPA_PLATFORM" = "wayland;xcb";
        "QT_STYLE_OVERRIDE" = "Adwaita-dark";
    };

    environment.etc = {
        "gtk-3.0/settings.ini" = {
            text = ''
                [Settings]
                gtk-theme-name=Adwaita-dark
                gtk-icon-theme-name=Adwaita
                gtk-application-prefer-dark-theme=1
            '';
        };
        "gtk-4.0/settings.ini" = {
            text = ''
                [Settings]
                gtk-theme-name=Adwaita-dark
                gtk-icon-theme-name=Adwaita
                gtk-application-prefer-dark-theme=1
            '';
        };
        "dunst/dunstrc" = {
            text = ''
                [global]
                font = Monospace 10
                background = ${theme.colors.bg}
                foreground = ${theme.colors.fg}
                frame_color = ${theme.colors.accent}
                frame_width = 2

                [urgency_low]
                background = ${theme.colors.bg}
                foreground = ${theme.colors.fg}

                [urgency_normal]
                background = ${theme.colors.bg}
                foreground = ${theme.colors.fg}

                [urgency_critical]
                background = #ff0000
                foreground = #ffffff
            '';
        };
        "kitty/kitty.conf" = {
            text = ''
                background = ${theme.colors.bg}
                foreground = ${theme.colors.fg}
                cursor = ${theme.colors.fg}
                selection_background = ${theme.colors.accent}
                selection_foreground = ${theme.colors.bg}
                color2 = ${theme.colors.accent}
                font_family = Monospace
                font_size = 10.0
            '';
        };
    };
}
