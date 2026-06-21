{ pkgs, config, ... }: {
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableKvm = true;
  virtualisation.virtualbox.host.addNetworkInterface = false;
  boot.kernelModules = [ "vboxdrv" "vboxnetadp" "vboxnetflt" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ virtualbox ];
}