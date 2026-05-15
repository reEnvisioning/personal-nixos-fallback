{ pkgs, ... }:

let
  simpleTheme = pkgs.stdenv.mkDerivation {
    pname = "plymouth-theme-simple";
    version = "1.0";
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/share/plymouth/themes/simple/resources
      sed "s|@out@|$out|g" ${./simple.plymouth} \
        > $out/share/plymouth/themes/simple/simple.plymouth
      cp -r ${./resources}/* $out/share/plymouth/themes/simple/resources/
    '';
  };
in {
  boot.plymouth = {
    enable = true;
    theme = "simple";
    themePackages = [ simpleTheme ];
  };

  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [ "quiet" ];
}
