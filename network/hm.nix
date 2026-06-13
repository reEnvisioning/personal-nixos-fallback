{ config, pkgs, lib, ... }:
let
  opensnitch-ui-wrapped = pkgs.opensnitch-ui.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
    dontWrapQtApps = true;
    preFixup = (old.preFixup or "") + ''
      wrapProgram "$out/bin/opensnitch-ui" --set QT_QPA_PLATFORM "xcb"
    '';
  });
in {
  home.packages = with pkgs; [
    opensnitch-ui-wrapped
  ];

    systemd.user.services.proxy-notify = {
      Unit = {
        Description = "Proxy connection state notification";
        After = [ "graphical-session.target" "default.target" ];
        Wants = [ "graphical-session.target" ];
        PartOf = [ "default.target" ];
      };
      Service = {
        Type = "simple";
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
        ExecStart = let
          pollScript = pkgs.writeShellScript "proxy-notify-poll" ''
            notified=""
            retries=5
            while true; do
              cur=$(cat /run/wireguard-monitor/wg-vpn-status 2>/dev/null || echo "")
              if [ -n "$cur" ] && [ "$cur" != "$notified" ]; then
                case "$cur" in
                  offline)
                    tries=0
                    while [ $tries -lt $retries ]; do
                      if ${pkgs.libnotify}/bin/notify-send -a "Proxy" --expire-time=86400000 -u critical \
                          "Proxy Offline" "Could not reach WireGuard server"; then
                        notified="$cur"
                        break
                      fi
                      tries=$((tries + 1))
                      sleep 1
                    done
                    ;;
                  connected)
                    tries=0
                    while [ $tries -lt $retries ]; do
                      if ${pkgs.libnotify}/bin/notify-send -a "Proxy" --expire-time=86400000 -u critical \
                          "Proxy Online" "WireGuard connection established"; then
                        notified="$cur"
                        break
                      fi
                      tries=$((tries + 1))
                      sleep 1
                    done
                    ;;
                esac
              fi
              sleep 2
            done
          '';
        in "${pollScript}";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
}
