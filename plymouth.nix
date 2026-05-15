{ pkgs, ... }:

let
  omarchyTheme = pkgs.stdenv.mkDerivation {
    pname = "plymouth-theme-omarchy";
    version = "1.0";
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/share/plymouth/themes/omarchy

      cat > $out/share/plymouth/themes/omarchy/omarchy.plymouth << 'PLYEND'
[Plymouth Theme]
Name=omarchy
ModuleName=script

[script]
ImageDir=@out@/share/plymouth/themes/omarchy
ScriptFile=@out@/share/plymouth/themes/omarchy/omarchy.script
PLYEND

      cat > $out/share/plymouth/themes/omarchy/omarchy.script << 'SCRIPTEND'
Window.SetBackgroundTopColor(0.101, 0.105, 0.149);
Window.SetBackgroundBottomColor(0.101, 0.105, 0.149);

logo_img = Image("logo.png");
logo = Sprite(logo_img);
logo.SetX(Window.GetWidth() / 2 - logo_img.GetWidth() / 2);
logo.SetY(Window.GetHeight() / 2 - logo_img.GetHeight() / 2 - 30);

message = Dialog();
message.SetEntryMessage("");
message.SetKeyboardType("password");
Window.AddPasswordDialog(message, 0.3, 0.55, 0.4, 0.06);
SCRIPTEND

      substituteInPlace $out/share/plymouth/themes/omarchy/omarchy.plymouth \
        --replace "@out@" "$out"

      cp ${./plymouth/logo.png} $out/share/plymouth/themes/omarchy/
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
