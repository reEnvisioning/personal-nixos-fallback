{ config, pkgs, lib, quickshellSrc, rethemePackage ? null, ... }:
let
  theme = import ./theme.nix;
  generators = import ./generators.nix;
  rethemeBin = if rethemePackage == null then "retheme" else "${rethemePackage}/bin/retheme";

  # Clean theme.json: only colors, mode, wallpapers, cursor, opacity, font
  mkCleanThemeJson = name: t: builtins.toJSON ({
    themeName = name;
    mode = t.mode;
    wallpaper = toString t.wallpaper;
    wallpapers = map (x: toString x) t.wallpapers;
    cursor_theme = t.cursor_theme;
    cursor_size = t.cursor_size;
    active_opacity = t.active_opacity;
    inactive_opacity = t.inactive_opacity;
    font = { family = "Monospace"; size = 10; };
    colors = t.colors;
  });

  bool = x: if x then "true" else "false";

  externalFor = t:
    if t.mode == "dark" then {
      gtkTheme = "Catppuccin-Mocha-Standard-Maroon-Dark";
      preferDark = true;
      localsendColor = "oled";
      obsStyle = "Acri";
      qtStyle = "adwaita-dark";
      kdeScheme = "BreezeDark";
      kdeWidgetStyle = "Fusion";
      gimpTheme = "Default";
      gimpColorScheme = "dark";
      browserDark = true;
    } else {
      gtkTheme = "Catppuccin-Latte-Standard-Pink";
      preferDark = false;
      localsendColor = "system";
      obsStyle = "Light";
      qtStyle = "Adwaita";
      kdeScheme = "BreezeLight";
      kdeWidgetStyle = "Fusion";
      gimpTheme = "Default";
      gimpColorScheme = "light";
      browserDark = false;
    };

  mkFileApp = app: target: filename: content: ''
    [meta]
    app = "${app}"
    schema = 1
    handler = "file"
    target = "${target}"
    filename = "${filename}"
    dynamic = false

    [content]
    text = """
    ${content}
    """
  '';

  mkSettingsApp = app: settings: ''
    [meta]
    app = "${app}"
    schema = 1
    handler = "settings"
    dynamic = false

    [settings]
    ${settings}
  '';

  mkAppConfigs = name: t:
    let e = externalFor t; in [
      {
        name = "reEnvisioning/themes/${name}/theme.json";
        value = {
          text = mkCleanThemeJson name t;
          force = true;
        };
      }
      {
        name = "reEnvisioning/themes/${name}/apps/kitty.toml";
        value.text = mkFileApp "kitty" "~/.config/kitty" "kitty.conf" (generators.mkKittyConf t);
      }
      {
        name = "reEnvisioning/themes/${name}/apps/btop.toml";
        value.text = mkFileApp "btop" "~/.config/btop/themes" "current.theme" (generators.mkBtopTheme t);
      }
      {
        name = "reEnvisioning/themes/${name}/apps/yazi.toml";
        value.text = mkFileApp "yazi" "~/.config/yazi" "theme.toml" (generators.mkYaziTheme t);
      }
      {
        name = "reEnvisioning/themes/${name}/apps/localsend_app.toml";
        value.text = mkSettingsApp "localsend_app" ''
          mode = "${t.mode}"
          color = "${e.localsendColor}"
          target = "~/.local/share/org.localsend.localsend_app"
          filename = "shared_preferences.json"
        '';
      }
      {
        name = "reEnvisioning/themes/${name}/apps/gtk.toml";
        value.text = mkSettingsApp "gtk" ''
          theme = "${e.gtkTheme}"
          prefer_dark = ${bool e.preferDark}
        '';
      }
      {
        name = "reEnvisioning/themes/${name}/apps/qt.toml";
        value.text = mkSettingsApp "qt" ''style = "${e.qtStyle}"'';
      }
      {
        name = "reEnvisioning/themes/${name}/apps/kdenlive.toml";
        value.text = mkSettingsApp "kdenlive" ''
          scheme = "${e.kdeScheme}"
          widget_style = "${e.kdeWidgetStyle}"
        '';
      }
      {
        name = "reEnvisioning/themes/${name}/apps/obs.toml";
        value.text = mkSettingsApp "obs" ''style = "${e.obsStyle}"'';
      }
      {
        name = "reEnvisioning/themes/${name}/apps/gimp.toml";
        value.text = mkSettingsApp "gimp" ''
          theme = "${e.gimpTheme}"
          color_scheme = "${e.gimpColorScheme}"
        '';
      }
      {
        name = "reEnvisioning/themes/${name}/apps/firefox.toml";
        value.text = mkSettingsApp "firefox" ''dark_mode = ${bool e.browserDark}'';
      }
      {
        name = "reEnvisioning/themes/${name}/apps/librewolf.toml";
        value.text = mkSettingsApp "librewolf" ''dark_mode = ${bool e.browserDark}'';
      }
    ];

  themeJsonConfigs = builtins.listToAttrs (lib.flatten (map
    (name: mkAppConfigs name theme.all.${name})
    (builtins.attrNames theme.all)));
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
  } // themeJsonConfigs;

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
