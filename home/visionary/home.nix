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

  systemd.user.services.proxy-notify = {
    Unit = {
      Description = "Proxy connection state notification";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = let
        pollScript = pkgs.writeShellScript "proxy-notify-poll" ''
          last=""
          while true; do
            cur=$(cat /tmp/wg-vpn-status 2>/dev/null || echo "")
            if [ -n "$cur" ] && [ "$cur" != "$last" ]; then
              case "$cur" in
                unreachable)
                  notify-send -a "Proxy" -u critical "Proxy Offline" \
                    "WireGuard server unreachable — using direct connection"
                  ;;
                connected)
                  if [ "$last" = "unreachable" ] || [ "$last" = "" ]; then
                    notify-send -a "Proxy" "Proxy Online" \
                      "WireGuard connection established"
                  fi
                  ;;
              esac
              last="$cur"
            fi
            sleep 5
          done
        '';
      in "${pollScript}";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
