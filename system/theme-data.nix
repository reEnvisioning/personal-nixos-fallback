{ ... }:
let
  theme = import ../theme/theme.nix;

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
  environment.etc = themeJsonConfigs // yaziThemeConfigs;
}
