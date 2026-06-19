{ config, pkgs, lib, ... }:
let
  theme = import ./theme.nix;

  mkThemeJson = name: t: builtins.toJSON ({
    name = name;
    mode = t.mode;
  } // t.colors);

  mkMetaJson = name: t: builtins.toJSON {
    name = name;
    wallpaper = toString t.wallpaper;
    wallpapers = map (x: toString x) t.wallpapers;
    gtkThemeName = t.gtk.themeName;
    localsend_color = t.localsend_color;
    obs_style = t.obs_style;
    KDEwidgetStyle = t.KDEwidgetStyle;
    cursor_theme = t.cursor_theme;
    cursor_size = t.cursor_size;
    active_opacity = t.active_opacity;
    inactive_opacity = t.inactive_opacity;
    font = { family = "Monospace"; size = 10; };
  };

  themeJsonConfigs = builtins.listToAttrs (lib.flatten (map (name: [
    {
      name = "reEnvisioning/themes/${name}/theme.json";
      value = {
        text = mkThemeJson name theme.all.${name};
        force = true;
      };
    }
    {
      name = "reEnvisioning/themes/${name}/meta.json";
      value = {
        text = mkMetaJson name theme.all.${name};
        force = true;
      };
    }
    {
      name = "reEnvisioning/yazi-themes/${name}.toml";
      value = {
        source = theme.all.${name}.yazi;
        force = true;
      };
    }
  ]) (builtins.attrNames theme.all)));
in {
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

  gtk = {
    enable = true;
    iconTheme.name = "Adwaita";
  };

  xdg.configFile = {
    "kitty/kitty.conf".force = true;
    "gtk-3.0/settings.ini".force = true;
    "gtk-4.0/settings.ini".force = true;
    "reEnvisioning/config.json" = {
      force = true;
      text = builtins.toJSON { uiScale = 1; };
    };
    "reEnvisioning/shell.json" = {
      force = true;
      text = import ./reEnvisioning/config.schema.nix {
        theme = { name = theme.default; } // theme.all.${theme.default};
        uiScale = 1;
      };
    };
    "quickshell" = {
      source = pkgs.runCommandLocal "quickshell-config" {} ''
  mkdir -p $out
  cp -r ${./quickshell}/* $out/
'';
      recursive = true;
    };
    "quickshell/user".source = ./resources/user;
  } // themeJsonConfigs;
}
