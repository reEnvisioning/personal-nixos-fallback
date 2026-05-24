let
  hexHelper = color: builtins.substring 1 (builtins.stringLength color) color;
  default = "void";

  mkCatppuccin = variant: accent: {
    package = "catppuccin";
    inherit variant accent;
    size = "standard";
    tweaks = [];
    themeName = "Catppuccin-${variant}-Standard-${accent}-Dark";
  };

  mkCatppuccinLight = variant: accent: {
    package = "catppuccin";
    inherit variant accent;
    size = "standard";
    tweaks = [];
    themeName = "Catppuccin-${variant}-Standard-${accent}";
  };

  allThemes = {
    void = {
      mode = "dark";
      localsend_color = "oled";
      obs_style = "Acri";
      KDEwidgetStyle = "Fusion";
      wallpaper = ./resources/wallpaper/void.png;
      wallpapers = [
        ./resources/wallpaper/void.png
      ];
      yazi = ./resources/yazi/void.toml;
      active_opacity = 0.9;
      inactive_opacity = 0.85;
      cursor_theme = "Vanilla-DMZ";
      cursor_size = 24;
      gtk = mkCatppuccin "Mocha" "Mauve";
      colors = {
 	crust             = "#000000";
    	background        = "#080808";
    	accent_dark       = "#000000";
    	accent            = "#0E0E0E";
    	accent_light      = "#121212";
    	borderInactive    = "#161616";
    	borderFocused     = "#1C1C1C";
    	backgroundAccent  = "#1A1A1A";
    	overlay2          = "#1E1E1E";
    	surface2          = "#262626";
    	overlay1          = "#2C2C2C";
    	highlighted       = "#363636";
    	red               = "#404040";
    	blue              = "#444444";
    	sapphire          = "#494949";
    	maroon            = "#525252";
    	mauve             = "#565656";
    	lavender          = "#606060";
    	peach             = "#626262";
    	sky               = "#656565";
    	green             = "#6C6C6C";
    	cyan              = "#707070";
    	pink              = "#808080";
    	magenta           = "#848484";
    	flamingo          = "#8C8C8C";
    	yellow            = "#989898";
    	rosewater         = "#A0A0A0";
    	subtext0          = "#888888";
    	subtext1          = "#999999";
    	text              = "#C0C0C0";
	};
    };

    radiance = {
      mode = "light";
      localsend_color = "system";
      obs_style = "Light";
      KDEwidgetStyle = "Fusion";
      wallpaper = ./resources/wallpaper/radiance.png;
      wallpapers = [
        ./resources/wallpaper/radiance.png
      ];
      yazi = ./resources/yazi/radiance.toml;
      active_opacity = 0.9;
      inactive_opacity = 0.85;
      cursor_theme = "Vanilla-DMZ";
      cursor_size = 24;
      gtk = mkCatppuccinLight "Latte" "Blue";
      colors = {
    	crust             = "#F8F8F8";
    	background        = "#F0F0F0";
    	accent_dark       = "#FCFCFC";
    	accent            = "#ECECEC";
    	accent_light      = "#E8E8E8";
    	borderInactive    = "#E4E4E4";
    	borderFocused     = "#D8D8D8";
    	backgroundAccent  = "#EAEAEA";
    	overlay2          = "#E6E6E6";
    	surface2          = "#DCDCDC";
    	overlay1          = "#D4D4D4";
    	highlighted       = "#C8C8C8";
    	red               = "#666666";
    	blue              = "#6A6A6A";
    	sapphire          = "#6E6E6E";
    	maroon            = "#727272";
    	mauve             = "#767676";
    	lavender          = "#7E7E7E";
    	peach             = "#828282";
    	sky               = "#868686";
    	green             = "#8A8A8A";
    	cyan              = "#8E8E8E";
    	pink              = "#929292";
    	magenta           = "#969696";
    	flamingo          = "#9A9A9A";
    	yellow            = "#9E9E9E";
    	rosewater         = "#A2A2A2";
    	subtext0          = "#555555";
    	subtext1          = "#444444";
    	text              = "#222222";
	};
    };

    sakura = {
      mode = "light";
      localsend_color = "yaru";
      obs_style = "Light";
      KDEwidgetStyle = "Fusion";
      wallpaper = ./resources/wallpaper/sakura.png;
      wallpapers = [
        ./resources/wallpaper/sakura.png
      ];
      yazi = ./resources/yazi/sakura.toml;
      active_opacity = 0.9;
      inactive_opacity = 0.85;
      cursor_theme = "Vanilla-DMZ";
      cursor_size = 24;
      gtk = mkCatppuccinLight "Latte" "Pink";
      colors = {
        background = "#FFFFFF";
        backgroundAccent = "#FFF0F0";
        highlighted = "#FFD6D6";
        text = "#2D2D2D";
        borderInactive = "#FFE0E0";
        borderFocused = "#FFB3B3";
        accent = "#E91E63";
        accent_light = "#FF80AB";
        accent_dark = "#AD1457";
        red = "#FF6B6B";
        green = "#66BB6A";
        yellow = "#FFD54F";
        blue = "#64B5F6";
        magenta = "#FF4081";
        cyan = "#4DD0E1";
        mauve = "#CE93D8";
        lavender = "#E1BEE7";
        pink = "#F48FB1";
        rosewater = "#FCE4EC";
        flamingo = "#FFCDD2";
        maroon = "#EF5350";
        peach = "#FFAB91";
        sky = "#81D4FA";
        sapphire = "#4FC3F7";
        surface2 = "#FFF5F5";
        overlay1 = "#FFEBEE";
        overlay2 = "#FFE0E0";
        crust = "#FFFFFF";
        subtext0 = "#757575";
        subtext1 = "#616161";
      };
    };

    bloody = {
      mode = "dark";
      localsend_color = "oled";
      obs_style = "Acri";
      KDEwidgetStyle = "Fusion";
      wallpaper = ./resources/wallpaper/bloody.png;
      wallpapers = [
        ./resources/wallpaper/bloody.png
      ];
      yazi = ./resources/yazi/bloody.toml;
      active_opacity = 0.9;
      inactive_opacity = 0.85;
      cursor_theme = "Vanilla-DMZ";
      cursor_size = 24;
      gtk = mkCatppuccin "Mocha" "Maroon";
      colors = {
        background = "#0A0000";
        backgroundAccent = "#1A0A08";
        highlighted = "#2A1410";
        text = "#C0B0B0";
        borderInactive = "#120404";
        borderFocused = "#3A1818";
        accent = "#8B0000";
        accent_light = "#A52A2A";
        accent_dark = "#4A0000";
        red = "#CC3333";
        green = "#446644";
        yellow = "#886644";
        blue = "#445577";
        magenta = "#883366";
        cyan = "#446666";
        mauve = "#774477";
        lavender = "#554488";
        pink = "#884466";
        rosewater = "#553333";
        flamingo = "#442222";
        maroon = "#662222";
        peach = "#774433";
        sky = "#445566";
        sapphire = "#335577";
        surface2 = "#1A0A08";
        overlay1 = "#150606";
        overlay2 = "#100404";
        crust = "#050000";
        subtext0 = "#887777";
        subtext1 = "#776666";
      };
    };
  };
in {
  inherit default;
  all = allThemes;

  mode = allThemes.${default}.mode;
  wallpaper = allThemes.${default}.wallpaper;
  localsend_color = allThemes.${default}.localsend_color;
  active_opacity = allThemes.${default}.active_opacity;
  inactive_opacity = allThemes.${default}.inactive_opacity;
  cursor_theme = allThemes.${default}.cursor_theme;
  cursor_size = allThemes.${default}.cursor_size;
  font = {
    family = "Monospace";
    size = 10;
  };
  hex = hexHelper;
  colors = allThemes.${default}.colors;
}
