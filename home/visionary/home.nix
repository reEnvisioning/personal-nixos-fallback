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

  systemd.user.services.wg-vpn-poller = let
    pollerScript = pkgs.writeShellScript "wg-vpn-poller" ''
      prev=""
      while true; do
        s=$(cat /tmp/wg-vpn-status 2>/dev/null || echo disconnected)
        if [ "$s" != "$prev" ]; then
          case "$s" in
            connected)
              notify-send -r 9999 -t 1 -a Proxy "" 2>/dev/null
              ;;
            unreachable)
              notify-send -r 9999 -u critical -a Proxy "VPN server unreachable — using direct connection"
              ;;
            *)
              notify-send -r 9999 -u critical -a Proxy "VPN disconnected"
              ;;
          esac
          prev="$s"
        fi
        sleep 5
      done
    '';
  in {
    Unit = {
      Description = "WireGuard VPN notification poller";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = pollerScript;
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
