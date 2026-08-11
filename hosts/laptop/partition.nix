{ modulesPath, lib, ... }:
let
  # Keep this in sync with laptop/disko.nix after inspecting the target laptop.
  diskDevice = "/dev/disk/by-id/nvme-LAPTOP_DISK_ID";
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  fileSystems."/boot" = {
    device = "${diskDevice}-part1";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  fileSystems."/" = {
    device = "/dev/mapper/crypt-root";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."crypt-root" = {
    device = "${diskDevice}-part2";
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
