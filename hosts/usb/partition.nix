{ lib, ... }: {
  fileSystems."/boot" = {
    device = "/dev/sda1";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  fileSystems."/" = {
    device = "/dev/mapper/crypt-usb";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."crypt-usb" = {
    device = "/dev/sda2";
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
