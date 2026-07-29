{ config, pkgs, lib, quickshellSrc, rethemePackage ? null, ... }:
let
  theme = import ./theme.nix;
  rethemeBin = if rethemePackage == null then "retheme" else "${rethemePackage}/bin/retheme";
in
{
  imports = [ ./theme-reload.nix ];

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
      background = "${theme.colors.background}";
      foreground = "${theme.colors.text}";
      cursor = "${theme.colors.cursor}";
      selection_background = "${theme.colors.highlighted}";
      selection_foreground = "${theme.colors.background}";
    };
    extraConfig = ''
      color1 ${theme.colors.red}
      color2 ${theme.colors.green}
      color3 ${theme.colors.yellow}
      color4 ${theme.colors.blue}
      color5 ${theme.colors.magenta}
      color6 ${theme.colors.cyan}
    '';
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "${config.home.homeDirectory}/.config/btop/themes/current.theme";
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
    "kitty/kitty.conf".force = true;
    "gtk-3.0/settings.ini".force = true;
    "gtk-4.0/settings.ini".force = true;

    # Ecosystem root
    "reEnvisioning/ecosystem.toml" = {
      force = true;
      text = ''
        version = 1
        schema = "reEnvisioning-ecosystem"
        appdata_dir = "reEnvisioning/appdata"
        usr_dir = "reEnvisioning/usr"

        [theme]
        current = "${theme.default}"
        runtime_path = "reEnvisioning/active/theme.json"
        themes_dir = "reEnvisioning/themes"
        active_dir = "reEnvisioning/active"
      '';
    };

    # App-owned data/config scaffolds
    "reEnvisioning/appdata/reShell/config.toml" = {
      force = true;
      text = ''
        ui_scale = 1
      '';
    };

    "reEnvisioning/appdata/reTheme/.keep".text = "";
    "reEnvisioning/appdata/reWallpaper/wallpapers/.keep".text = "";
    "reEnvisioning/usr/.keep".text = "";

    "quickshell" = {
      source = quickshellSrc;
      force = true;
    };
  };

  home.activation.restoreTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    CURRENT_THEME="$(cat "$HOME/.config/reEnvisioning/active/current-theme" 2>/dev/null || echo "${theme.default}")"
    THEME_DIR="$HOME/.config/reEnvisioning/themes/$CURRENT_THEME"
    if [ ! -f "$THEME_DIR/theme.json" ]; then
      CURRENT_THEME="${theme.default}"
      THEME_DIR="$HOME/.config/reEnvisioning/themes/$CURRENT_THEME"
    fi
    if [ -f "$THEME_DIR/theme.json" ]; then
      RETHEME_ROOT="$HOME/.config/reEnvisioning" ${rethemeBin} switch "$CURRENT_THEME"

      # Apply settings handlers (GTK, Firefox, LibreWolf, etc.) until reTheme owns them.
      export PATH="/run/current-system/sw/bin:$PATH"
      external-theme
    fi
  '';
}
