{ pkgs, ... }:

{
  boot.plymouth = {
    enable = true;
    theme = "vision";
    themePackages = [
      (pkgs.stdenv.mkDerivation {
        pname = "plymouth-theme-vision";
        version = "1.0";
        src = ./resources/plymouth;
        installPhase = ''
          mkdir -p $out/share/plymouth/themes/vision
          cp -r * $out/share/plymouth/themes/vision/
          substituteInPlace $out/share/plymouth/themes/vision/vision.plymouth \
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
