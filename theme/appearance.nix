{ config, pkgs, lib, quickshellSrc, rethemePackage ? null, ... }:
let
  cfg = config.appearance;

  theme = import ./theme.nix;

  # Collect all wallpaper store paths to prevent garbage collection
  allWallpaperPaths =
    let
      themes = builtins.attrValues theme.all;
    in
    lib.unique (lib.flatten (map (t: [ t.wallpaper ] ++ t.wallpapers) themes));

  catppuccin-mocha = pkgs.catppuccin-gtk.override {
    variant = "mocha";
    accents = [ "blue" "mauve" "maroon" "pink" ];
  };

  catppuccin-latte = pkgs.catppuccin-gtk.override {
    variant = "latte";
    accents = [ "blue" "pink" ];
  };
in
{
  options.appearance.users = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Users that get theme + quickshell config applied";
  };

  config = lib.mkIf (cfg.users != [ ]) {
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

    environment.systemPackages = (with pkgs; [
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
      (writeShellScriptBin "shell" (builtins.readFile "${quickshellSrc}/scripts/shell"))
      (writeShellScriptBin "switch-theme" (builtins.readFile ./switch-theme))
      (writeShellScriptBin "external-theme" (builtins.readFile ./external-theme))
      (writeShellScriptBin "switch-wallpaper" (builtins.readFile ./switch-wallpaper))
      (writeShellScriptBin "indicator" (builtins.readFile "${quickshellSrc}/scripts/indicator"))
      (writeShellScriptBin "volume" (builtins.readFile "${quickshellSrc}/scripts/volume"))
      (writeShellScriptBin "brightness" (builtins.readFile "${quickshellSrc}/scripts/brightness"))
      (writeShellScriptBin "dnd" (builtins.readFile "${quickshellSrc}/scripts/dnd"))
      (writeShellScriptBin "idle-toggle" (builtins.readFile "${quickshellSrc}/scripts/idle-toggle"))
      (writeShellScriptBin "state" (builtins.readFile "${quickshellSrc}/scripts/state"))
      (writeShellScriptBin "mic" (builtins.readFile "${quickshellSrc}/scripts/mic"))
      (writeShellScriptBin "powerprofile" (builtins.readFile "${quickshellSrc}/scripts/powerprofile"))
    ]) ++ lib.optional (rethemePackage != null) rethemePackage;

    home-manager.users = builtins.listToAttrs (map
      (username: {
        name = username;
        value.imports = [ ./hm.nix ];
      })
      cfg.users);
  };
}
