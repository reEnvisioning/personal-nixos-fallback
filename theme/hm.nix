{ config, pkgs, lib, hostname, ... }:
let
  theme = import ./theme.nix;

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
    "quickshell/shell.qml".source = ./quickshell/shell.qml;
    "${hostname}/config.json" = {
      force = true;
      text = builtins.toJSON { uiScale = 1; };
    };
    "quickshell/lib".source = ./quickshell/lib;
    "quickshell/bar".source = ./quickshell/bar;
    "quickshell/notif".source = ./quickshell/notif;
    "quickshell/clip".source = ./quickshell/clip;
    "quickshell/launcher".source = ./quickshell/launcher;
    "quickshell/user".source = ./resources/user;
  };
}
