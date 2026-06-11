{ config, ... }: {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  boot.kernelParams = [ "nvidia-drm.modeset=1" "nvidia-drm.fbdev=1" "video=1920x1080" ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
