{ ... }: {
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.consoleMode = "max";
    systemd-boot.configurationLimit = 20;
    efi.canTouchEfiVariables = true;
  };
}
