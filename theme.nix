let
  hexHelper = color: builtins.substring 1 (builtins.stringLength color) color;

  allThemes = {
    void = {
      mode = "dark";
      localsend_color = "oled";
      obs_style = "Acri";
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
        red = "#54383D";
        green = "#3C563A";
        yellow = "#594F3B";
        blue = "#3D475B";
        magenta = "#5E3E55";
        cyan = "#40605B";
        mauve = "#473A58";
        lavender = "#3B3F59";
        pink = "#563A4F";
        rosewater = "#543A38";
        flamingo = "#553939";
        maroon = "#5A3C41";
        peach = "#5B483D";
        sky = "#3E585C";
        sapphire = "#3E545E";
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
        red = "#AB8188";
        green = "#87AD83";
        yellow = "#AEA186";
        blue = "#8895B0";
        magenta = "#B18BA7";
        cyan = "#8DB3AD";
        mauve = "#9685AD";
        lavender = "#868BAE";
        pink = "#AD83A2";
        rosewater = "#AB8481";
        flamingo = "#AC8282";
        maroon = "#AF878E";
        peach = "#B09788";
        sky = "#89ABB1";
        sapphire = "#8BA5B1";
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
