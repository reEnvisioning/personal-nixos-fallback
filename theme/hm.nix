{ config, pkgs, lib, ... }:
let
  theme = import ./theme.nix;

  uiScale = "1";

  shellQml = builtins.replaceStrings
    ["1 // scale-config"]
    ["${uiScale} // scale-config"]
    (builtins.readFile ./quickshell/shell.qml);

  fuzzy-launcher = pkgs.rustPlatform.buildRustPackage {
    pname = "fuzzy-launcher";
    version = "0.1.0";
    src = ../rust/fuzzy-launcher;
    cargoHash = lib.fakeHash;
  };
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
      font_size = 1.0 * theme.font.size;
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
    theme.name = "adw-gtk3-dark";
    theme.package = pkgs.adw-gtk3;
    gtk4.theme = null;
    iconTheme.name = "Adwaita";
    gtk3.extraConfig = {
      "gtk-application-prefer-dark-theme" = if theme.mode == "dark" then 1 else 0;
    };
    gtk4.extraConfig = {
      "gtk-application-prefer-dark-theme" = if theme.mode == "dark" then 1 else 0;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = if theme.mode == "dark" then "prefer-dark" else "default";
    };
  };

  home.packages = [ fuzzy-launcher ];

  xdg.configFile = {
    "kitty/kitty.conf".force = true;
    "gtk-3.0/settings.ini".force = true;
    "gtk-4.0/settings.ini".force = true;
    "quickshell/shell.qml" = {
      force = true;
      text = shellQml;
    };
    "quickshell/lib".source = ./quickshell/lib;
    "quickshell/bar".source = ./quickshell/bar;
    "quickshell/notif".source = ./quickshell/notif;
    "quickshell/clip".source = ./quickshell/clip;
    "quickshell/launcher".source = ./quickshell/launcher;
    "quickshell/user".source = ./resources/user;
  };
}
