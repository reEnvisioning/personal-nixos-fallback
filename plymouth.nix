{ pkgs, ... }:

let
  simpleTheme = pkgs.stdenv.mkDerivation {
    pname = "plymouth-theme-simple";
    version = "1.0";
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/share/plymouth/themes/simple/resources
      cp ${./plymouth/simple.plymouth} $out/share/plymouth/themes/simple/
      cp ${./plymouth}/*.png $out/share/plymouth/themes/simple/resources/
      substituteInPlace $out/share/plymouth/themes/simple/simple.plymouth \
        --replace "@out@" "$out" \
        --replace "Cantarell" "DejaVu Sans"
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
