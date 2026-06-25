{ config, pkgs, lib, ... }:
let
  theme = import ./theme.nix;

  quickshellDir = pkgs.runCommandLocal "quickshell-config" {} ''
    mkdir -p $out
    cp -r ${./quickshell}/* $out/
    cp -r ${./resources/user} $out/user
  '';

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

  mkBtopTheme = name: t: ''
    theme[main_bg]=${t.colors.background}
    theme[main_fg]=${t.colors.text}
    theme[title]=${t.colors.text}
    theme[hi_fg]=${t.colors.mauve}
    theme[selected_bg]=${t.colors.highlighted}
    theme[selected_fg]=${t.colors.text}
    theme[inactive_fg]=${t.colors.subtext0}
    theme[graph_text]=${t.colors.mauve}
    theme[meter_bg]=${t.colors.overlay2}
    theme[proc_misc]=${t.colors.mauve}
    theme[cpu_box]=${t.colors.mauve}
    theme[mem_box]=${t.colors.green}
    theme[net_box]=${t.colors.maroon}
    theme[proc_box]=${t.colors.blue}
    theme[div_line]=${t.colors.overlay1}
    theme[temp_start]=${t.colors.green}
    theme[temp_mid]=${t.colors.yellow}
    theme[temp_end]=${t.colors.red}
    theme[cpu_start]=${t.colors.cyan}
    theme[cpu_mid]=${t.colors.sapphire}
    theme[cpu_end]=${t.colors.lavender}
    theme[free_start]=${t.colors.mauve}
    theme[free_mid]=${t.colors.lavender}
    theme[free_end]=${t.colors.blue}
    theme[cached_start]=${t.colors.sapphire}
    theme[cached_mid]=${t.colors.blue}
    theme[cached_end]=${t.colors.lavender}
    theme[available_start]=${t.colors.peach}
    theme[available_mid]=${t.colors.maroon}
    theme[available_end]=${t.colors.red}
    theme[used_start]=${t.colors.green}
    theme[used_mid]=${t.colors.cyan}
    theme[used_end]=${t.colors.sky}
    theme[download_start]=${t.colors.peach}
    theme[download_mid]=${t.colors.maroon}
    theme[download_end]=${t.colors.red}
    theme[upload_start]=${t.colors.green}
    theme[upload_mid]=${t.colors.cyan}
    theme[upload_end]=${t.colors.sky}
    theme[process_start]=${t.colors.sapphire}
    theme[process_mid]=${t.colors.lavender}
    theme[process_end]=${t.colors.mauve}
  '';

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
    {
      name = "reEnvisioning/btop-themes/${name}.theme";
      value = {
        text = mkBtopTheme name theme.all.${name};
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

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "${config.home.homeDirectory}/.config/btop/themes/reEnvisioning.theme";
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
      source = quickshellDir;
      force = true;
    };
    "btop/themes/reEnvisioning.theme" = {
      text = mkBtopTheme theme.default theme.all.${theme.default};
      force = true;
    };
  } // themeJsonConfigs;
}
