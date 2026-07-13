{ pkgs, ... }:
let
  themeReloadScript = pkgs.writeShellScript "theme-reload.sh" ''
    RT="$HOME/.config/reEnvisioning/theme.json"
    # Apply niri focus-ring colors from the active theme
    if [ -f "$RT" ]; then
      BORDER_FOCUSED=$(jq -r '.colors.borderFocused' "$RT" 2>/dev/null || echo "")
      BORDER_INACTIVE=$(jq -r '.colors.borderInactive' "$RT" 2>/dev/null || echo "")
      [ -n "$BORDER_FOCUSED" ] && niri msg config layout.focus-ring.active-color "$BORDER_FOCUSED" 2>/dev/null || true
      [ -n "$BORDER_INACTIVE" ] && niri msg config layout.focus-ring.inactive-color "$BORDER_INACTIVE" 2>/dev/null || true
    fi
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
