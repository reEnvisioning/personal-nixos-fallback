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
      After = [ "default.target" ];
      PartOf = [ "default.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = let
        pollScript = pkgs.writeShellScript "proxy-notify-poll" ''
          notified=""
          while true; do
            cur=$(cat /run/wg-proxy/wg-vpn-status 2>/dev/null || echo "")
            if [ -n "$cur" ] && [ "$cur" != "$notified" ]; then
              case "$cur" in
                offline)
                  ${pkgs.libnotify}/bin/notify-send -a "Proxy" --expire-time=86400000 -u critical \
                    "Proxy Offline" "Could not reach WireGuard server" \
                    && notified="$cur"
                  ;;
                connected)
                  ${pkgs.libnotify}/bin/notify-send -a "Proxy" --expire-time=86400000 -u critical \
                    "Proxy Online" "WireGuard connection established" \
                    && notified="$cur"
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
