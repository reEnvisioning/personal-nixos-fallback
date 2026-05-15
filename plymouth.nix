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
ImageDir=$out/share/plymouth/themes/omarchy
ScriptFile=$out/share/plymouth/themes/omarchy/omarchy.script
PLYEND

      cat > $out/share/plymouth/themes/omarchy/omarchy.script << 'SCRIPTEND'
Window.SetBackgroundTopColor(0.101, 0.105, 0.149);
Window.SetBackgroundBottomColor(0.101, 0.105, 0.149);

logo_img = Image("logo.png");
logo = Sprite(logo_img);
logo.SetX(Window.GetWidth() / 2 - logo_img.GetWidth() / 2);
logo.SetY(Window.GetHeight() / 2 - logo_img.GetHeight() / 2);

entry_img = Image("entry.png");
lock_img = Image("lock.png");
bullet_img = Image("bullet.png");

entry = Sprite(entry_img);
entry.SetX(Window.GetWidth() / 2 - entry_img.GetWidth() / 2);
entry.SetY(logo.GetY() + logo_img.GetHeight() + 40);
entry.SetZ(10001);
entry.SetOpacity(0);

lock = Sprite(lock_img);
lock.SetX(entry.GetX() - lock_img.GetWidth() - 15);
lock.SetY(entry.GetY() + entry_img.GetHeight() / 2 - lock_img.GetHeight() / 2);
lock.SetZ(10001);
lock.SetOpacity(0);

fun display_password_callback(prompt, bullets) {
  lock.SetOpacity(1);
  entry.SetOpacity(1);
  for (i = 0; bullet_sprites[i]; i++)
    bullet_sprites[i].SetOpacity(0);
  for (i = 0; i < bullets; i++) {
    if (!bullet_sprites[i]) {
      bullet_sprites[i] = Sprite(bullet_img);
      bullet_sprites[i].SetPosition(
        entry.GetX() + 20 + i * 12,
        entry.GetY() + entry_img.GetHeight() / 2 - 3.5,
        10002
      );
    }
    bullet_sprites[i].SetOpacity(1);
  }
}

fun display_normal_callback() {
  lock.SetOpacity(0);
  entry.SetOpacity(0);
  for (i = 0; bullet_sprites[i]; i++)
    bullet_sprites[i].SetOpacity(0);
}

Plymouth.SetDisplayPasswordFunction(display_password_callback);
Plymouth.SetDisplayNormalFunction(display_normal_callback);
SCRIPTEND

      cp ${./plymouth}/*.png $out/share/plymouth/themes/omarchy/
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
