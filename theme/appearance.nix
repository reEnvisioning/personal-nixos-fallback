{ config, pkgs, lib, ... }:
let
  cfg = config.appearance;

  theme = import ./theme.nix;

  # Collect all wallpaper store paths to prevent garbage collection
  allWallpaperPaths = let
    themes = builtins.attrValues theme.all;
  in lib.unique (lib.flatten (map (t: [t.wallpaper] ++ t.wallpapers) themes));

  catppuccin-mocha = pkgs.catppuccin-gtk.override {
    variant = "mocha";
    accents = [ "blue" "mauve" "maroon" "pink" ];
  };

  catppuccin-latte = pkgs.catppuccin-gtk.override {
    variant = "latte";
    accents = [ "blue" "pink" ];
  };
in {
  options.appearance.users = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "Users that get theme + quickshell config applied";
  };

  config = lib.mkIf (cfg.users != []) {
    # Pin all wallpaper store paths into the system closure so they
    # cannot be garbage-collected even if string context is lost by toJSON
    system.extraDependencies = allWallpaperPaths;

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
      catppuccin-mocha
      catppuccin-latte
      (writeShellScriptBin "shell" (builtins.readFile ./quickshell/scripts/shell))
      (writeShellScriptBin "switch-theme" (builtins.readFile ./switch-theme))
      (writeShellScriptBin "switch-wallpaper" (builtins.readFile ./switch-wallpaper))
      (writeShellScriptBin "indicator" (builtins.readFile ./quickshell/scripts/indicator))
      (writeShellScriptBin "volume" (builtins.readFile ./quickshell/scripts/volume))
      (writeShellScriptBin "brightness" (builtins.readFile ./quickshell/scripts/brightness))
      (writeShellScriptBin "dnd" (builtins.readFile ./quickshell/scripts/dnd))
      (writeShellScriptBin "idle-toggle" (builtins.readFile ./quickshell/scripts/idle-toggle))
      (writeShellScriptBin "state" (builtins.readFile ./quickshell/scripts/state))
      (writeShellScriptBin "mic" (builtins.readFile ./quickshell/scripts/mic))
      (writeShellScriptBin "powerprofile" (builtins.readFile ./quickshell/scripts/powerprofile))
    ];

    home-manager.users = builtins.listToAttrs (map (username: {
      name = username;
      value.imports = [ ./hm.nix ];
    }) cfg.users);
  };
}
