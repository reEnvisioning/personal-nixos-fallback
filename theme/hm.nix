{ config, pkgs, lib, rethemePackage ? null, ... }:
let
  theme = import ./theme.nix;
  rethemeBin = if rethemePackage == null then "retheme" else "${rethemePackage}/bin/retheme";
in
{
  home.pointerCursor = {
    package = pkgs.vanilla-dmz;
    name = theme.cursor_theme;
    size = theme.cursor_size;
    gtk.enable = true;
    x11.enable = true;
  };

  programs.kitty = {
    enable = true;
    settings = {
      font_family = "${theme.font.family}";
      font_size = theme.font.size;
      confirm_os_window_close = 0;
    };
    extraConfig = ''
      include ~/.config/kitty/retheme-base16.conf
    '';
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "${config.home.homeDirectory}/.config/btop/themes/retheme-base16.theme";
      theme_background = false;
      truecolor = true;
      rounded_corners = true;
      graph_symbol = "braille";
      shown_boxes = "cpu mem net proc";
      update_ms = 2000;
    };
  };

  gtk = {
    enable = true;
    iconTheme.name = "Adwaita";
  };

  xdg.configFile = {
    "reEnvisioning/ecosystem.toml" = {
      force = true;
      text = ''
        version = 1
        schema = "reEnvisioning-ecosystem"
        appdata_dir = "reEnvisioning/appdata"
        usr_dir = "reEnvisioning/usr"

        [theme]
        current = "${theme.default}"
        runtime_path = "reEnvisioning/active/theme.toml"
        themes_dir = "reEnvisioning/themes"
        active_dir = "reEnvisioning/active"
      '';
    };
    "reEnvisioning/appdata/reTheme/.keep".text = "";
    "reEnvisioning/appdata/reWallpaper/wallpapers/.keep".text = "";
    "reEnvisioning/usr/.keep".text = "";
  };

  home.activation.restoreTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    CURRENT_THEME="$(cat "$HOME/.config/reEnvisioning/active/current-theme" 2>/dev/null || echo "${theme.default}")"
    THEME_DIR="$HOME/.config/reEnvisioning/themes/$CURRENT_THEME"
    if [ ! -f "$THEME_DIR/theme.toml" ]; then
      CURRENT_THEME="${theme.default}"
      THEME_DIR="$HOME/.config/reEnvisioning/themes/$CURRENT_THEME"
    fi
    if [ -f "$THEME_DIR/theme.toml" ]; then
      if ! RETHEME_ROOT="$HOME/.config/reEnvisioning" ${rethemeBin} switch "$CURRENT_THEME"; then
        echo "warning: could not apply theme '$CURRENT_THEME'; keeping current runtime theme" >&2
      fi
    fi
  '';
}
