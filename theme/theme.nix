let
  default = "sakura";

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
      wallpaper = ./resources/wallpaper/void.png;
      wallpapers = [
        ./resources/wallpaper/void.png
      ];
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
        border            = "#1C1C1C";
        backgroundAccent  = "#1A1A1A";
        overlay2          = "#1E1E1E";
        surface          = "#505050";
        overlay1          = "#2C2C2C";
        highlighted       = "#363636";
        element_background = "#363636";
        ui_error          = "#5A4A4A";
        ui_warning        = "#5A5A4A";
        ui_success        = "#4A5A4A";
        ui_info           = "#4A4A5A";
        ui_hint           = "#484848";
        ui_match          = "#6A6A4A";
        cursor            = "#0E0E0E";
        red               = "#666666";
        blue              = "#6A6A6A";
        sapphire          = "#6E6E6E";
        maroon            = "#727272";
        mauve             = "#767676";
        lavender          = "#7A7A7A";
        peach             = "#7E7E7E";
        sky               = "#828282";
        green             = "#868686";
        cyan              = "#8A8A8A";
        pink              = "#8E8E8E";
        magenta           = "#929292";
        flamingo          = "#969696";
        yellow            = "#9A9A9A";
        rosewater         = "#A0A0A0";
        subtext0          = "#A8A8A8";
        subtext1          = "#B0B0B0";
        text              = "#C0C0C0";
      };
    };

    ink = {
      mode = "light";
      wallpaper = ./resources/wallpaper/ink.png;
      wallpapers = [
        ./resources/wallpaper/ink.png
      ];
      active_opacity = 0.9;
      inactive_opacity = 0.85;
      cursor_theme = "Vanilla-DMZ";
      cursor_size = 24;
      gtk = mkCatppuccinLight "Latte" "Blue";
      colors = {
        crust             = "#FEFEFE";
        background        = "#FFFFFF";
        accent_dark       = "#FFFFFF";
        accent            = "#F0F0F0";
        accent_light      = "#E8E8E8";
        border            = "#000000";
        backgroundAccent  = "#F5F5F5";
        overlay2          = "#ECECEC";
        surface          = "#909090";
        overlay1          = "#E0E0E0";
        highlighted       = "#D8D8D8";
        element_background = "#D8D8D8";
        ui_error          = "#3A2A2A";
        ui_warning        = "#3A3A2A";
        ui_success        = "#2A3A2A";
        ui_info           = "#2A2A3A";
        ui_hint           = "#777777";
        ui_match          = "#3A3A2A";
        cursor            = "#F0F0F0";
        red               = "#464646";
        blue              = "#4A4A4A";
        sapphire          = "#4E4E4E";
        maroon            = "#525252";
        mauve             = "#565656";
        lavender          = "#5E5E5E";
        peach             = "#626262";
        sky               = "#666666";
        green             = "#6A6A6A";
        cyan              = "#6E6E6E";
        pink              = "#727272";
        magenta           = "#767676";
        flamingo          = "#7A7A7A";
        yellow            = "#7E7E7E";
        rosewater         = "#828282";
        subtext0          = "#555555";
        subtext1          = "#333333";
        text              = "#000000";
      };
    };

    sakura = {
      mode = "light";
      wallpaper = ./resources/wallpaper/sakura.png;
      wallpapers = [
        ./resources/wallpaper/sakura.png
      ];
      active_opacity = 0.9;
      inactive_opacity = 0.85;
      cursor_theme = "Vanilla-DMZ";
      cursor_size = 24;
      gtk = mkCatppuccinLight "Latte" "Pink";
      colors = {
        crust             = "#FFF0F0";
        background        = "#FFF5F5";
        accent_dark       = "#F5DCDC";
        accent            = "#F0CECE";
        accent_light      = "#EBBDBD";
        border            = "#E8C0C0";
        backgroundAccent  = "#F5E0E0";
        overlay2          = "#F2DDDD";
        surface          = "#DEBCBC";
        overlay1          = "#EDD0D0";
        highlighted       = "#F0CECE";
        element_background = "#F0CECE";
        ui_error          = "#D32F2F";
        ui_warning        = "#E65100";
        ui_success        = "#388E3C";
        ui_info           = "#1976D2";
        ui_hint           = "#757575";
        ui_match          = "#F57C00";
        cursor            = "#F0CECE";
        red               = "#D64545";
        blue              = "#1976D2";
        sapphire          = "#0277BD";
        maroon            = "#C62828";
        mauve             = "#7B1FA2";
        lavender          = "#7E57C2";
        peach             = "#E65100";
        sky               = "#0288D1";
        green             = "#43A047";
        cyan              = "#00838F";
        pink              = "#E05A77";
        magenta           = "#E91E63";
        flamingo          = "#CC7A7A";
        yellow            = "#D4A017";
        rosewater         = "#D46A7A";
        subtext0          = "#757575";
        subtext1          = "#616161";
        text              = "#2D2D2D";
      };
    };

    horror = {
      mode = "dark";
      wallpaper = ./resources/wallpaper/horror.png;
      wallpapers = [
        ./resources/wallpaper/horror.png
        ./resources/wallpaper/backrooms.png
      ];
      active_opacity = 0.9;
      inactive_opacity = 0.85;
      cursor_theme = "Vanilla-DMZ";
      cursor_size = 24;
      gtk = mkCatppuccin "Mocha" "Maroon";
      colors = {
        crust             = "#000000";
        background        = "#000000";
        accent_dark       = "#C9A881";
        accent            = "#E6CC9A";
        accent_light      = "#ECDFB1";
        border            = "#E6CC9A";
        backgroundAccent  = "#000000";
        overlay2          = "#241C14";
        surface          = "#2A2018";
        overlay1          = "#1E1810";
        highlighted       = "#E6CC9A";
        element_background = "#2A2018";
        ui_error          = "#D4553A";
        ui_warning        = "#E8A040";
        ui_success        = "#7ABA5E";
        ui_info           = "#7AAECE";
        ui_hint           = "#B0A090";
        ui_match          = "#F0B040";
        text              = "#F0E0CC";
        subtext0          = "#B0A090";
        subtext1          = "#C8B8A8";
        cursor            = "#E6CC9A";
        red               = "#E86A4A";
        green             = "#9ABA5E";
        yellow            = "#F0C040";
        blue              = "#4A7C9A";
        magenta           = "#E07A9A";
        cyan              = "#6ABAAA";
        mauve             = "#B07AAA";
        lavender          = "#9A8ABA";
        pink              = "#E08A9A";
        rosewater         = "#E0A080";
        flamingo          = "#D0806A";
        maroon            = "#B84A3A";
        peach             = "#F0A850";
        sky               = "#7AAABA";
        sapphire          = "#6A9AAA";
      };
    };
  };
in {
  inherit default;
  all = allThemes;

  mode = allThemes.${default}.mode;
  wallpaper = allThemes.${default}.wallpaper;
  active_opacity = allThemes.${default}.active_opacity;
  inactive_opacity = allThemes.${default}.inactive_opacity;
  cursor_theme = allThemes.${default}.cursor_theme;
  cursor_size = allThemes.${default}.cursor_size;
  font = {
    family = "Monospace";
    size = 10;
  };
  colors = allThemes.${default}.colors;
}
