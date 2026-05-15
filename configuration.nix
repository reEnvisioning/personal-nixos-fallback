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
                command = "${pkgs.tuigreet}/bin/tuigreet --cmd start-hyprland";
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
            "vboxusers"
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

    boot.kernelPackages = pkgs.linuxPackages;
    boot.kernelModules = [ "btusb" ];

    boot.initrd.luks.devices."luks-26fcc57f-6de2-4ea0-9c1e-9411b537d0ae".device = "/dev/disk/by-uuid/26fcc57f-6de2-4ea0-9c1e-9411b537d0ae";

    boot.initrd.systemd.enable = true;

    boot.plymouth = {
        enable = true;
        theme = "minimal";
        themePackages = [
            (pkgs.stdenv.mkDerivation {
                pname = "plymouth-theme-minimal";
                version = "1.0";
                dontUnpack = true;
                installPhase = ''
                    mkdir -p $out/share/plymouth/themes/minimal
                    cat > $out/share/plymouth/themes/minimal/minimal.plymouth << PLYEND
[Plymouth Theme]
Name = minimal
ModuleName = two-step

[two-step]
BackgroundStartColor=0x000000
BackgroundEndColor=0x000000
DialogHorizontalAlignment=.5
DialogVerticalAlignment=.5
Transition=none
TransitionDuration=0.0
MessageBelowAnimation=true
DialogClearsFirmwareBackground=true
UseFirmwareBackground=true

[boot-up]
UseFirmwareBackground=true
UseEndAnimation=false

[shutdown]
UseFirmwareBackground=true
UseEndAnimation=false

[reboot]
UseFirmwareBackground=true
UseEndAnimation=false

[updates]
UseFirmwareBackground=false
SuppressMessages=true
UseProgressBar=true
ProgressBarShowPercentComplete=true
Title=Updating...
SubTitle=Do not turn off your computer.

[system-upgrade]
UseFirmwareBackground=false
SuppressMessages=true
UseProgressBar=true
ProgressBarShowPercentComplete=true
Title=Upgrading...
SubTitle=Do not turn off your computer.

[firmware-upgrade]
UseFirmwareBackground=false
SuppressMessages=true
UseProgressBar=true
ProgressBarShowPercentComplete=true
Title=Upgrading firmware...
SubTitle=Do not turn off your computer.
PLYEND
                '';
            })
        ];
    };

    boot.consoleLogLevel = 3;
    boot.initrd.verbose = false;
    boot.kernelParams = [
        "quiet"
        "udev.log_level=3"
        "systemd.show_status=auto"
    ];

    virtualisation.virtualbox.host.enable = true;

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
        temurin-bin-21
    ];

    environment.variables = {
        "QT_QPA_PLATFORM" = "wayland;xcb";
        "ADW_DISABLE_PORTAL" = "1";
        "QT_QPA_PLATFORMTHEME" = "qt5ct";
        "XDG_CURRENT_DESKTOP" = "Hyprland";
    };

}
