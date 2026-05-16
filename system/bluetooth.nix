{ pkgs, ... }: {
  boot.kernelModules = [ "btusb" ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  services.blueman.enable = true;
}
