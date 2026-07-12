{ pkgs, ... }:
let
  themeReloadScript = pkgs.writeShellScript "theme-reload.sh" ''
    # Signal kitty to reload config
    pkill -SIGUSR1 kitty 2>/dev/null || true
    # Signal btop to reload config
    killall -USR2 btop 2>/dev/null || true
    # Yazi auto-reloads via inotifywait on theme.toml — no signal needed
  '';
in {
  systemd.user.services.theme-reload = {
    Unit = {
      Description = "Reload apps on theme change";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${themeReloadScript}";
    };
  };

  systemd.user.paths.theme-reload = {
    Unit = {
      Description = "Watch theme.json for changes";
    };
    Path = {
      PathModified = "%h/.config/reEnvisioning/theme.json";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
