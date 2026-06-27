{ config, lib, pkgs, ... }: {
  hardware.cpu.amd.updateMicrocode = true;
  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelParams = [ "amd_pstate=active" ];
}
