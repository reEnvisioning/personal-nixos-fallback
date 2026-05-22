{ pkgs, config, lib, ... }:

{
  # === INTEL CPU SETTINGS ===
  
  # Intel CPU microcode updates (security/bug fixes)
  hardware.cpu.intel.updateMicrocode = true;


  # Enable OpenGL/Vulkan
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Load NVIDIA driver for Xorg and Wayland (Hyprland)
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Open-source kernel module (Turing/RTX 20+ series and newer)
    open = true;

    # Enable kernel modesetting (prevents tearing)
    modesetting.enable = true;

    # Enable NVIDIA settings GUI (accessible via `nvidia-settings`)
    nvidiaSettings = true;

    # Use stable driver package (matches current kernel)
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Environment variables for Wayland/Hyprland + NVIDIA
  environment.sessionVariables = {
    # Force Electron/CEF apps to use Wayland
    NIXOS_OZONE_WL = "1";
  };

  # NVIDIA kernel parameters
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
  ];

  boot.initrd.luks.devices."luks-26fcc57f-6de2-4ea0-9c1e-9411b537d0ae".device = "/dev/disk/by-uuid/26fcc57f-6de2-4ea0-9c1e-9411b537d0ae";

  time.timeZone = "Europe/Berlin";
  console.keyMap = "us";

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
}
