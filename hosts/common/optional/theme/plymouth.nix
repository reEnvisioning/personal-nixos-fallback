{ inputs, pkgs, ... }:

{
  boot.plymouth = {
    enable = true;
    theme = "besein";
    themePackages = [ inputs.plymouth.packages.${pkgs.stdenv.hostPlatform.system}.default ];
  };

  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "udev.log_level=3"
    "systemd.show_status=auto"
  ];
}
