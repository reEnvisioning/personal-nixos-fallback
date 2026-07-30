{ config, pkgs, lib, rethemePackage ? null, ... }:
let
  cfg = config.appearance;

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
    description = "Users that get theme configuration applied";
  };

  config = lib.mkIf (cfg.users != [ ]) {
    environment.variables = {
      "QT_QPA_PLATFORM" = "wayland;xcb";
      "ADW_DISABLE_PORTAL" = "1";
      "QT_QPA_PLATFORMTHEME" = "qt5ct";
      "XDG_CURRENT_DESKTOP" = "niri";
      "TERMINAL" = "kitty";
    };

    environment.systemPackages = (with pkgs; [
      adw-gtk3
      adwaita-qt
      adwaita-qt6
      libsForQt5.qt5ct
      kdePackages.qt6ct
      qt5.qtwayland
      qt6.qtwayland
      jq
      gawk
      catppuccin-mocha
      catppuccin-latte
      (writeShellScriptBin "external-theme" (builtins.readFile ./external-theme))
      (writeShellScriptBin "switch-wallpaper" (builtins.readFile ./switch-wallpaper))
    ]) ++ lib.optional (rethemePackage != null) rethemePackage;

    home-manager.users = builtins.listToAttrs (map
      (username: {
        name = username;
        value.imports = [ ./hm.nix ];
      })
      cfg.users);
  };
}
