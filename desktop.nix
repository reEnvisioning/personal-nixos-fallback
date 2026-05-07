{ pkgs, config, lib, ... }:

{
  # === INTEL CPU SETTINGS ===
  
  # Intel CPU microcode updates (security/bug fixes)
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # === NVIDIA RTX 3060 LITE (DESKTOP) ===
  # RTX 3060 is Turing architecture (supports open-source kernel modules)

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
}
