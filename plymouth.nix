{ pkgs, ... }:

let
  omarchyTheme = pkgs.stdenv.mkDerivation {
    pname = "plymouth-theme-omarchy";
    version = "1.0";
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/share/plymouth/themes/omarchy
      cp ${./plymouth/omarchy.plymouth} $out/share/plymouth/themes/omarchy/
      cp ${./plymouth/omarchy.script} $out/share/plymouth/themes/omarchy/
      cp ${./plymouth}/*.png $out/share/plymouth/themes/omarchy/
      substituteInPlace $out/share/plymouth/themes/omarchy/omarchy.plymouth \
        --replace "/usr/share/plymouth/themes/omarchy" "$out/share/plymouth/themes/omarchy" \
        --replace "Cantarell" "DejaVu Sans"
    '';
  };
in {
  boot.plymouth = {
    enable = true;
    theme = "omarchy";
    themePackages = [ omarchyTheme ];
  };

  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [ "quiet" ];
}
