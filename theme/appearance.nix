{ config, pkgs, lib, hostname, ... }:
let
  cfg = config.appearance;

  theme = import ./theme.nix;

  mkThemeJson = name: t: builtins.toJSON {
    name = name;
    mode = t.mode;
    localsend_color = t.localsend_color;
    obs_style = t.obs_style;
    KDEwidgetStyle = t.KDEwidgetStyle;
    wallpaper = toString t.wallpaper;
    wallpapers = map (x: toString x) t.wallpapers;
    gtkThemeName = t.gtk.themeName;
    colors = t.colors;
  };

  catppuccin-mocha = pkgs.catppuccin-gtk.override {
    variant = "mocha";
    accents = [ "blue" "mauve" "maroon" "pink" ];
  };

  catppuccin-latte = pkgs.catppuccin-gtk.override {
    variant = "latte";
    accents = [ "blue" "pink" ];
  };

  themeJsonConfigs = builtins.listToAttrs (map (name: {
    name = "${hostname}/themes/${name}.json";
    value.text = mkThemeJson name theme.all.${name};
  }) (builtins.attrNames theme.all));

  yaziThemeConfigs = builtins.listToAttrs (map (name: {
    name = "${hostname}/yazi-themes/${name}.toml";
    value.source = theme.all.${name}.yazi;
  }) (builtins.attrNames theme.all));
in {
  options.appearance.users = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "Users that get theme + quickshell config applied";
  };

  config = lib.mkIf (cfg.users != []) {
    environment.etc = themeJsonConfigs // yaziThemeConfigs;

    environment.variables = {
      "QT_QPA_PLATFORM" = "wayland;xcb";
      "ADW_DISABLE_PORTAL" = "1";
      "QT_QPA_PLATFORMTHEME" = "qt5ct";
      "XDG_CURRENT_DESKTOP" = "niri";
      "TERMINAL" = "kitty";
    };

    environment.systemPackages = with pkgs; [
      quickshell
      wl-clipboard
      libnotify
      adw-gtk3
      adwaita-qt
      adwaita-qt6
      libsForQt5.qt5ct
      kdePackages.qt6ct
      qt5.qtwayland
      qt6.qtwayland
      jq
      inotify-tools
      catppuccin-mocha
      catppuccin-latte
      (writeShellScriptBin "switch-theme" (builtins.readFile ./switch-theme))
      (writeShellScriptBin "switch-wallpaper" (builtins.readFile ./switch-wallpaper))
      (writeShellScriptBin "indicator" (builtins.readFile ./quickshell/scripts/indicator))
      (writeShellScriptBin "volume" (builtins.readFile ./quickshell/scripts/volume))
      (writeShellScriptBin "brightness" (builtins.readFile ./quickshell/scripts/brightness))
      (writeShellScriptBin "dnd" (builtins.readFile ./quickshell/scripts/dnd))
      (writeShellScriptBin "idle-toggle" (builtins.readFile ./quickshell/scripts/idle-toggle))
      (writeShellScriptBin "state" (builtins.readFile ./quickshell/scripts/state))
      (writeShellScriptBin "mic" (builtins.readFile ./quickshell/scripts/mic))
    ];

    home-manager.users = builtins.listToAttrs (map (username: {
      name = username;
      value.imports = [ ./hm.nix ];
    }) cfg.users);
  };
}
