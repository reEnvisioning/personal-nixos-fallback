{
  mode = "dark"; # "dark" or "light"

  wallpaper = "/headspace/wallpaper/wallpaper.png";

  font = {
    family = "Monospace";
    size = 10;
  };

  hex = color: builtins.substring 1 (builtins.stringLength color) color;

  colors = {
    background = "#000000";
    backgroundAccent = "#494949";
    highlighted = "#616161";
    text = "#C2C2C2";
    borderInactive = "#181818";
    borderFocused = "#303030";

    red = "#494949";
    green = "#494949";
    yellow = "#494949";
    blue = "#494949";
    magenta = "#494949";
    cyan = "#494949";
  };
}
