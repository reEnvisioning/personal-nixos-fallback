{ config, pkgs, lib, quickshellSrc, ... }:
let
  theme = import ./theme.nix;
  external = import ./external.nix { inherit config pkgs lib; };
  generators = import ./generators.nix;

  # Clean theme.json: only colors, mode, wallpapers, cursor, opacity, font
  mkCleanThemeJson = name: t: builtins.toJSON ({
    name = name;
    mode = t.mode;
    wallpaper = toString t.wallpaper;
    wallpapers = map (x: toString x) t.wallpapers;
    cursor_theme = t.cursor_theme;
    cursor_size = t.cursor_size;
    active_opacity = t.active_opacity;
    inactive_opacity = t.inactive_opacity;
    font = { family = "Monospace"; size = 10; };
  } // t.colors);

  themeJsonConfigs = builtins.listToAttrs (lib.flatten (map (name: let t = theme.all.${name}; in [
    {
      name = "reEnvisioning/themes/${name}/theme.json";
      value = {
        text = mkCleanThemeJson name t;
        force = true;
      };
    }
    {
      name = "reEnvisioning/themes/${name}/kitty.conf";
      value = {
        text = generators.mkKittyConf t;
        force = true;
      };
    }
    {
      name = "reEnvisioning/themes/${name}/btop.theme";
      value = {
        text = generators.mkBtopTheme t;
        force = true;
      };
    }
    {
      name = "reEnvisioning/themes/${name}/yazi.toml";
      value = {
        text = generators.mkYaziTheme t;
        force = true;
      };
    }
  ]) (builtins.attrNames theme.all)));
in {
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
      cursor = "${theme.colors.text}";
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
    "reEnvisioning/ecosystem.json" = {
      force = true;
      text = builtins.toJSON {
        version = 1;
        schema = "reEnvisioning-ecosystem";
          theme = {
            current = theme.default;
            runtimePath = "reEnvisioning/theme.json";
            themesDir = "reEnvisioning/themes";
            externalDir = "reEnvisioning/external";
          };
        stateDir = "reEnvisioning/state";
        configDir = "reEnvisioning/config";
        dataDir = "reEnvisioning/data";
      };
    };

    # Ecosystem-wide settings
    "reEnvisioning/config/general.json" = {
      force = true;
      text = builtins.toJSON { uiScale = 1; };
    };

    # App config directory scaffold
    "reEnvisioning/config/apps/.empty" = {
      text = "";
    };

    "reEnvisioning/reShell/user" = {
      source = ./resources/user;
      force = true;
      recursive = true;
    };

    "quickshell" = {
      source = quickshellSrc;
      force = true;
    };
  } // themeJsonConfigs // external.xdg.configFile;
}
