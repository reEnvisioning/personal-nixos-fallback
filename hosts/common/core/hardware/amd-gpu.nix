{ config, lib, pkgs, ... }: {
  hardware.graphics.enable = true;

  hardware.amdgpu.initrd.enable = true;

  services.xserver.videoDrivers = [ "amdgpu" ];
}
