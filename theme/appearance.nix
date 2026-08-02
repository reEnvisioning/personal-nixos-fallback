{ config, pkgs, lib, rethemePackage ? null, ... }:
let
  cfg = config.appearance;
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
      "QT_QPA_PLATFORMTHEME" = "qt5ct";
      "SAL_USE_VCLPLUGIN" = "gtk3";
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
