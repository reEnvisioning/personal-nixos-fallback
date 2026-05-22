{ pkgs, ... }:

{
  boot.plymouth = {
    enable = true;
    theme = "connect";
    themePackages = [
      (pkgs.stdenv.mkDerivation {
        pname = "plymouth-theme-connect";
        version = "1.0";
        src = ../theme/resources/connect;
        installPhase = ''
          mkdir -p $out/share/plymouth/themes/connect
          cp -r * $out/share/plymouth/themes/connect/
          substituteInPlace $out/share/plymouth/themes/connect/connect.plymouth \
            --replace "/usr" "$out"
        '';
      })
    ];
  };

  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "udev.log_level=3"
    "systemd.show_status=auto"
  ];
}
