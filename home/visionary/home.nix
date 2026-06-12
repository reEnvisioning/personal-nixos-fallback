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
      CUR=$(cat /tmp/wg-vpn-status 2>/dev/null || echo "unknown")
      LAST=$(cat /tmp/wg-notify-last 2>/dev/null || echo "none")

      if [ "$CUR" != "$LAST" ] && [ "$CUR" != "pending" ] && [ "$CUR" != "unknown" ]; then
        case "$CUR" in
          connected)    notify-send -r 9999 -a Proxy "VPN connected" ;;
          unreachable)  notify-send -r 9999 -a Proxy "VPN server unreachable — using direct connection" ;;
          disconnected) notify-send -r 9999 -a Proxy "VPN disconnected" ;;
        esac
      fi

      echo "$CUR" > /tmp/wg-notify-last
    '';
  in {
    Unit = {
      Description = "Show WireGuard connection status";
    };
    Service = {
      Type = "oneshot";
      ExecStart = notifyScript;
    };
    Install = {
      WantedBy = lib.mkForce [ ];
    };
  };

  systemd.user.timers.wg-notify = {
    Unit = {
      Description = "Poll WireGuard status every 30s";
    };
    Timer = {
      OnBootSec = "10s";
      OnUnitActiveSec = "30s";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
