let
  hexHelper = color: builtins.substring 1 (builtins.stringLength color) color;

  allThemes = {
    void = {
      mode = "dark";
      localsend_color = "oled";
      obs_style = "Acri";
      wallpaper = ./resources/wallpaper/void.png;
      yazi = ./resources/yazi/void.toml;
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
        red = "#464646";
        green = "#484848";
        yellow = "#4A4A4A";
        blue = "#4C4C4C";
        magenta = "#4E4E4E";
        cyan = "#505050";
        mauve = "#494949";
        lavender = "#4A4A4A";
        pink = "#484848";
        rosewater = "#464646";
        flamingo = "#474747";
        maroon = "#4B4B4B";
        peach = "#4C4C4C";
        sky = "#4D4D4D";
        sapphire = "#4E4E4E";
        surface2 = "#494949";
        overlay1 = "#494949";
        overlay2 = "#494949";
        crust = "#000000";
        subtext0 = "#AAAAAA";
        subtext1 = "#B6B6B6";
      };
    };

    radiance = {
      mode = "light";
      localsend_color = "system";
      obs_style = "Light";
      wallpaper = ./resources/wallpaper/radiance.png;
      yazi = ./resources/yazi/radiance.toml;
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
        red = "#969696";
        green = "#989898";
        yellow = "#9A9A9A";
        blue = "#9C9C9C";
        magenta = "#9E9E9E";
        cyan = "#A0A0A0";
        mauve = "#999999";
        lavender = "#9A9A9A";
        pink = "#989898";
        rosewater = "#969696";
        flamingo = "#979797";
        maroon = "#9B9B9B";
        peach = "#9C9C9C";
        sky = "#9D9D9D";
        sapphire = "#9E9E9E";
        surface2 = "#9E9E9E";
        overlay1 = "#9E9E9E";
        overlay2 = "#9E9E9E";
        crust = "#FFFFFF";
        subtext0 = "#969696";
        subtext1 = "#828282";
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
