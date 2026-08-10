{ modulesPath, ... }: {
  imports = [ (modulesPath + "/profiles/all-hardware.nix") ];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
    configurationLimit = 20;
  };
  boot.loader.efi.canTouchEfiVariables = false;
}
