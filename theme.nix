let
  hexHelper = color: builtins.substring 1 (builtins.stringLength color) color;

  allThemes = {
    void = {
      mode = "dark";
      localsend_color = "oled";
      wallpaper = ./wallpaper/void.png;
      yazi = ./yazi-themes/void.toml;
      colors = {
        background = "#000000";
        backgroundAccent = "#494949";
        highlighted = "#616161";
        text = "#C2C2C2";
        borderInactive = "#181818";
        borderFocused = "#303030";
        accent = "#000000";
        accent_light = "#000000";
        accent_dark = "#000000";
        red = "#494949";
        green = "#494949";
        yellow = "#494949";
        blue = "#494949";
        magenta = "#494949";
        cyan = "#494949";
      };
    };

    radiance = {
      mode = "light";
      localsend_color = "system";
      wallpaper = ./wallpaper/radiance.png;
      yazi = ./yazi-themes/radiance.toml;
      colors = {
        background = "#FFFFFF";
        backgroundAccent = "#E7E7E7";
        highlighted = "#868686";
        text = "#6E6E6E";
        borderInactive = "#CFCFCF";
        borderFocused = "#B6B6B6";
        accent = "#000000";
        accent_light = "#000000";
        accent_dark = "#000000";
        red = "#9E9E9E";
        green = "#9E9E9E";
        yellow = "#9E9E9E";
        blue = "#9E9E9E";
        magenta = "#9E9E9E";
        cyan = "#9E9E9E";
      };
    };
  };
in {
  default = "void";
  all = allThemes;

  mode = allThemes.void.mode;
  wallpaper = allThemes.void.wallpaper;
  localsend_color = allThemes.void.localsend_color;
  font = {
    family = "Monospace";
    size = 10;
  };
  hex = hexHelper;
  colors = allThemes.void.colors;
}
