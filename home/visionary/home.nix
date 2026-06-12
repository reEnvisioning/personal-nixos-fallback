{ config, pkgs, inputs, lib, username, ... }:
let
  opensnitch-ui-wrapped = pkgs.opensnitch-ui.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
    dontWrapQtApps = true;
    preFixup = (old.preFixup or "") + ''
      wrapProgram "$out/bin/opensnitch-ui" --set QT_QPA_PLATFORM "xcb"
    '';
  });
in {
  home = {
    stateVersion = "26.05";
    username = username;
    homeDirectory = "/home/${username}";
  };

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    mpv
    prismlauncher
    localsend
    procps
    gimp
    jetbrains.idea-oss
    kdePackages.kdenlive
    libreoffice-qt
    obs-studio
    davinci-resolve-studio
    ocl-icd
    opensnitch-ui-wrapped
  ];

  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    settings = {
      program_options = {
        file_manager = "yazi";
      };
    };
  };

  systemd.user.services.wg-notify = let
    notifyScript = pkgs.writeShellScript "wg-notify" ''
      msg=$(cat /tmp/wg-notify 2>/dev/null)
      if [ -n "$msg" ]; then
        notify-send -r 9999 -a Proxy "$msg"
      fi
      rm -f /tmp/wg-notify
    '';
  in {
    Unit = {
      Description = "Show WireGuard connection notifications";
    };
    Service = {
      Type = "oneshot";
      ExecStart = notifyScript;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.paths.wg-notify = {
    Unit = {
      Description = "Watch for WireGuard connection changes";
    };
    Path = {
      PathChanged = [ "/tmp/wg-notify" ];
      Unit = "wg-notify.service";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
