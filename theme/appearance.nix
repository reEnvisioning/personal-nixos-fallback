{ config, pkgs, lib, ... }:
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
  options.appearance.users = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "Users that get theme + quickshell config applied";
  };

  config = lib.mkIf (cfg.users != []) {
    environment.etc = themeJsonConfigs // yaziThemeConfigs;

    environment.systemPackages = with pkgs; [
      quickshell
      wl-clipboard
      libnotify
      adw-gtk3
      adwaita-qt
      adwaita-qt6
      libsForQt5.qt5ct
      kdePackages.qt6ct
      jq
      inotify-tools
      (writeShellScriptBin "switch-theme" (builtins.readFile ./switch-theme))
      (writeShellScriptBin "indicator" (builtins.readFile ./quickshell/scripts/indicator))
      (writeShellScriptBin "volume" (builtins.readFile ./quickshell/scripts/volume))
      (writeShellScriptBin "brightness" (builtins.readFile ./quickshell/scripts/brightness))
      (writeShellScriptBin "dnd" (builtins.readFile ./quickshell/scripts/dnd))
      (writeShellScriptBin "idle-toggle" (builtins.readFile ./quickshell/scripts/idle-toggle))
    ];

    home-manager.users = builtins.listToAttrs (map (username: {
      name = username;
      value.imports = [ ./hm.nix ];
    }) cfg.users);
  };
}
