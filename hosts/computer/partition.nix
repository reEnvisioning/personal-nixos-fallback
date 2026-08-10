{ modulesPath, lib, ... }:
let
  diskDevice = "/dev/nvme0n1";
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  fileSystems."/boot" = {
    device = "${diskDevice}p1";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  fileSystems."/" = {
    device = "/dev/mapper/crypt-root";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."crypt-root" = {
    device = "${diskDevice}p2";
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
