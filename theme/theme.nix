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
        surface2          = "#505050";
        overlay1          = "#2C2C2C";
        highlighted       = "#363636";
        # UI semantic colors (for UI elements, NOT syntax)
        ui_error          = "#5A4A4A";
        ui_warning        = "#5A5A4A";
        ui_success        = "#4A5A4A";
        ui_info           = "#4A4A5A";
        ui_hint           = "#484848";
        ui_match          = "#6A6A4A";
        # Text/syntax colors (for syntax highlighting only)
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

    radiance = {
      mode = "light";
      localsend_color = "system";
      obs_style = "Light";
      KDEwidgetStyle = "Fusion";
      wallpaper = ./resources/wallpaper/radiance.png;
      wallpapers = [
        ./resources/wallpaper/radiance.png
        ./resources/wallpaper/radiance2.png
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
        surface2          = "#A0A0A0";
        overlay1          = "#D4D4D4";
        highlighted       = "#C8C8C8";
        # UI semantic colors (for UI elements, NOT syntax)
        ui_error          = "#6A5A5A";
        ui_warning        = "#6A6A5A";
        ui_success        = "#5A6A5A";
        ui_info           = "#5A5A6A";
        ui_hint           = "#AAAAAA";
        ui_match          = "#5A5A4A";
        # Text/syntax colors (for syntax highlighting only)
        red               = "#565656";
        blue              = "#5A5A5A";
        sapphire          = "#5E5E5E";
        maroon            = "#626262";
        mauve             = "#666666";
        lavender          = "#6E6E6E";
        peach             = "#727272";
        sky               = "#767676";
        green             = "#7A7A7A";
        cyan              = "#7E7E7E";
        pink              = "#828282";
        magenta           = "#868686";
        flamingo          = "#8A8A8A";
        yellow            = "#8E8E8E";
        rosewater         = "#929292";
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
        crust             = "#FFF0F0";
        background        = "#FFF5F5";
        accent_dark       = "#F5DCDC";
        accent            = "#F0CECE";
        accent_light      = "#EBBDBD";
        borderInactive    = "#F0D6D6";
        borderFocused     = "#E8C0C0";
        backgroundAccent  = "#F5E0E0";
        overlay2          = "#F2DDDD";
        surface2          = "#DEBCBC";
        overlay1          = "#EDD0D0";
        highlighted       = "#F0CECE";
        # UI semantic colors (for UI elements, NOT syntax)
        ui_error          = "#D32F2F";
        ui_warning        = "#E65100";
        ui_success        = "#388E3C";
        ui_info           = "#1976D2";
        ui_hint           = "#757575";
        ui_match          = "#F57C00";
        # Text/syntax colors (for syntax highlighting only)
        text              = "#2D2D2D";
        subtext0          = "#757575";
        subtext1          = "#616161";
        red               = "#D64545";
        green             = "#43A047";
        yellow            = "#D4A017";
        blue              = "#1976D2";
        magenta           = "#E91E63";
        cyan              = "#00838F";
        mauve             = "#7B1FA2";
        lavender          = "#7E57C2";
        pink              = "#E05A77";
        rosewater         = "#D46A7A";
        flamingo          = "#CC7A7A";
        maroon            = "#C62828";
        peach             = "#E65100";
        sky               = "#0288D1";
        sapphire          = "#0277BD";
      };
    };

    horror = {
      mode = "dark";
      localsend_color = "oled";
      obs_style = "Acri";
      KDEwidgetStyle = "Fusion";
      wallpaper = ./resources/wallpaper/horror.png;
      wallpapers = [
        ./resources/wallpaper/horror.png
        ./resources/wallpaper/backrooms.png
      ];
      yazi = ./resources/yazi/horror.toml;
      active_opacity = 0.9;
      inactive_opacity = 0.85;
      cursor_theme = "Vanilla-DMZ";
      cursor_size = 24;
      gtk = mkCatppuccin "Mocha" "Maroon";
      colors = {
        crust             = "#0A0806";
        background        = "#120E0A";
        accent_dark       = "#070503";
        accent            = "#C48830";
        accent_light      = "#D4A040";
        borderInactive    = "#1E1610";
        borderFocused     = "#3A2818";
        backgroundAccent  = "#1A120C";
        overlay2          = "#281C12";
        surface2          = "#4C3420";
        overlay1          = "#221A12";
        highlighted       = "#3C2816";
        # UI semantic colors (for UI elements, NOT syntax)
        ui_error          = "#D4553A";
        ui_warning        = "#E8A040";
        ui_success        = "#7ABA5E";
        ui_info           = "#7AAECE";
        ui_hint           = "#B0A090";
        ui_match          = "#F0B040";
        # Text/syntax colors (for syntax highlighting only)
        text              = "#F0E0CC";
        subtext0          = "#B0A090";
        subtext1          = "#C8B8A8";
        red               = "#E86A4A";
        green             = "#9ABA5E";
        yellow            = "#F0C040";
        blue              = "#7AAECE";
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
  author = "reEnvisioning";
}
