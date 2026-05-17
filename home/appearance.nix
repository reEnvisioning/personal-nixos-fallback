{ config, pkgs, lib, ... }:
let
  theme = import ../theme/theme.nix;

  mkThemeJson = name: t: builtins.toJSON {
    name = name;
    mode = t.mode;
    localsend_color = t.localsend_color;
    obs_style = t.obs_style;
    wallpaper = toString t.wallpaper;
    colors = t.colors;
  };

  themeJsonConfigs = builtins.listToAttrs (map (name: {
    name = "headspace/themes/${name}.json";
    value.text = mkThemeJson name theme.all.${name};
  }) (builtins.attrNames theme.all));

  yaziThemeConfigs = builtins.listToAttrs (map (name: {
    name = "headspace/yazi-themes/${name}.toml";
    value.source = theme.all.${name}.yazi;
  }) (builtins.attrNames theme.all));
in {
  home.pointerCursor = {
    package = pkgs.vanilla-dmz;
    name = theme.cursor_theme;
    size = theme.cursor_size;
    gtk.enable = true;
    x11.enable = true;
  };

  xdg.configFile = (themeJsonConfigs // yaziThemeConfigs) // {
    "kitty/kitty.conf".force = true;
    "gtk-3.0/settings.ini".force = true;
    "gtk-4.0/settings.ini".force = true;
    "quickshell/shell.qml".force = true;
  };

  home.file."${config.xdg.configHome}/mozilla/firefox/profiles.ini".force = true;
  home.file."${config.xdg.configHome}/mozilla/firefox/default/user.js".force = true;


  programs.kitty = {
    enable = true;
    settings = {
      background = "${theme.colors.background}";
      foreground = "${theme.colors.text}";
      cursor = "${theme.colors.text}";
      selection_background = "${theme.colors.highlighted}";
      selection_foreground = "${theme.colors.background}";
      font_family = "${theme.font.family}";
      font_size = 1.0 * theme.font.size;
      confirm_os_window_close = 0;
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
    theme.name = "adw-gtk3-dark";
    theme.package = pkgs.adw-gtk3;
    gtk4.theme = null;
    iconTheme.name = "Adwaita";
    gtk3.extraConfig = { "gtk-application-prefer-dark-theme" = if theme.mode == "dark" then 1 else 0; };
    gtk4.extraConfig = { "gtk-application-prefer-dark-theme" = if theme.mode == "dark" then 1 else 0; };
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = if theme.mode == "dark" then "prefer-dark" else "default";
      };
    };
  };

  services.udiskie = {
    enable = true;
    settings = {
      program_options = {
        file_manager = "yazi";
      };
    };
  };
}
