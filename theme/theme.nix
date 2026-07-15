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
        border            = "#FFFFFF";
        backgroundAccent  = "#1A1A1A";
        overlay2          = "#1E1E1E";
        surface          = "#505050";
        bar              = "#505050";
        divider          = "#FFFFFF";
        overlay1          = "#2C2C2C";
        highlighted       = "#363636";
        element_background = "#1C1C1C";
        ui_error          = "#5A4A4A";
        ui_warning        = "#5A5A4A";
        ui_success        = "#4A5A4A";
        ui_info           = "#4A4A5A";
        ui_hint           = "#484848";
        ui_match          = "#6A6A4A";
        cursor            = "#DCDCDC";
        red               = "#666666";
        blue              = "#585858";
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
        text              = "#DCDCDC";

        # Interactive states
        interactive       = "#585858";
        interactive_hover = "#6A6A6A";
        interactive_pressed = "#4A4A4A";
        interactive_disabled = "#363636";
        focus             = "#6A6A6A";

        # Input/form states
        input_background  = "#1C1C1C";
        input_border      = "#363636";
        input_border_focus = "#6A6A6A";

        # Status indicators
        status_active     = "#4A5A4A";
        status_inactive   = "#363636";
        status_syncing    = "#4A4A5A";
        status_processing = "#5A5A4A";

        # Transfer/progress
        transfer_send     = "#585858";
        transfer_receive  = "#868686";
        transfer_complete = "#4A5A4A";
        transfer_failed   = "#5A4A4A";

        # Audio
        audio_waveform    = "#8A8A8A";
        audio_active      = "#868686";

        # Syntax/code
        syntax_keyword    = "#767676";
        syntax_string     = "#868686";
        syntax_number     = "#7E7E7E";
        syntax_comment    = "#A8A8A8";
        syntax_function   = "#6A6A6A";
        syntax_variable   = "#DCDCDC";

        # Charts/data
        chart_1           = "#666666";
        chart_2           = "#868686";
        chart_3           = "#9A9A9A";
        chart_4           = "#6A6A6A";
        chart_5           = "#929292";
        chart_6           = "#8A8A8A";
        chart_grid        = "#2C2C2C";

        # Depth/elevation
        elevation_1       = "#1E1E1E";
        elevation_2       = "#2C2C2C";
        elevation_3       = "#363636";
        overlay           = "#000000";

        # Text variants
        link              = "#6A6A6A";
        link_hover        = "#8A8A8A";
        placeholder       = "#A8A8A8";
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
        bar              = "#909090";
        divider          = "#000000";
        overlay1          = "#E0E0E0";
        highlighted       = "#D8D8D8";
        element_background = "#F0F0F0";
        ui_error          = "#3A2A2A";
        ui_warning        = "#3A3A2A";
        ui_success        = "#2A3A2A";
        ui_info           = "#2A2A3A";
        ui_hint           = "#777777";
        ui_match          = "#3A3A2A";
        cursor            = "#D0D0D0";
        red               = "#464646";
        blue              = "#4A4A4A";
        sapphire          = "#4E4E4E";
        maroon            = "#525252";
        mauve             = "#565656";
        lavender          = "#5E5E5E";
        peach             = "#626262";
        sky               = "#666666";
        green             = "#888888";
        cyan              = "#6E6E6E";
        pink              = "#727272";
        magenta           = "#767676";
        flamingo          = "#7A7A7A";
        yellow            = "#7E7E7E";
        rosewater         = "#828282";
        subtext0          = "#555555";
        subtext1          = "#333333";
        text              = "#000000";

        # Interactive states
        interactive       = "#333333";
        interactive_hover = "#222222";
        interactive_pressed = "#444444";
        interactive_disabled = "#999999";
        focus             = "#222222";

        # Input/form states
        input_background  = "#F0F0F0";
        input_border      = "#D8D8D8";
        input_border_focus = "#222222";

        # Status indicators
        status_active     = "#2A3A2A";
        status_inactive   = "#D8D8D8";
        status_syncing    = "#2A2A3A";
        status_processing = "#3A3A2A";

        # Transfer/progress
        transfer_send     = "#4A4A4A";
        transfer_receive  = "#888888";
        transfer_complete = "#2A3A2A";
        transfer_failed   = "#3A2A2A";

        # Audio
        audio_waveform    = "#6E6E6E";
        audio_active      = "#888888";

        # Syntax/code
        syntax_keyword    = "#565656";
        syntax_string     = "#888888";
        syntax_number     = "#626262";
        syntax_comment    = "#555555";
        syntax_function   = "#4A4A4A";
        syntax_variable   = "#000000";

        # Charts/data
        chart_1           = "#464646";
        chart_2           = "#888888";
        chart_3           = "#7E7E7E";
        chart_4           = "#4A4A4A";
        chart_5           = "#767676";
        chart_6           = "#6E6E6E";
        chart_grid        = "#E0E0E0";

        # Depth/elevation
        elevation_1       = "#F5F5F5";
        elevation_2       = "#ECECEC";
        elevation_3       = "#E0E0E0";
        overlay           = "#000000";

        # Text variants
        link              = "#333333";
        link_hover        = "#000000";
        placeholder       = "#555555";
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
        surface          = "#F5DADA";
        bar              = "#F5DADA";
        divider          = "#E8C0C0";
        overlay1          = "#EDD0D0";
        highlighted       = "#F5DADA";
        element_background = "#FFF0F0";
        ui_error          = "#D32F2F";
        ui_warning        = "#E65100";
        ui_success        = "#388E3C";
        ui_info           = "#1976D2";
        ui_hint           = "#757575";
        ui_match          = "#F57C00";
        cursor            = "#F0CECE";
        red               = "#D64545";
        blue              = "#42A5F5";
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

        # Interactive states
        interactive       = "#D08080";
        interactive_hover = "#C06060";
        interactive_pressed = "#E0A0A0";
        interactive_disabled = "#F5DADA";
        focus             = "#C06060";

        # Input/form states
        input_background  = "#FFF0F0";
        input_border      = "#E8C0C0";
        input_border_focus = "#D64545";

        # Status indicators
        status_active     = "#388E3C";
        status_inactive   = "#F5DADA";
        status_syncing    = "#1976D2";
        status_processing = "#E65100";

        # Transfer/progress
        transfer_send     = "#42A5F5";
        transfer_receive  = "#43A047";
        transfer_complete = "#388E3C";
        transfer_failed   = "#D32F2F";

        # Audio
        audio_waveform    = "#CC7A7A";
        audio_active      = "#43A047";

        # Syntax/code
        syntax_keyword    = "#7B1FA2";
        syntax_string     = "#43A047";
        syntax_number     = "#E65100";
        syntax_comment    = "#757575";
        syntax_function   = "#42A5F5";
        syntax_variable   = "#2D2D2D";

        # Charts/data
        chart_1           = "#D64545";
        chart_2           = "#43A047";
        chart_3           = "#D4A017";
        chart_4           = "#42A5F5";
        chart_5           = "#E91E63";
        chart_6           = "#00838F";
        chart_grid        = "#EDD0D0";

        # Depth/elevation
        elevation_1       = "#F5E0E0";
        elevation_2       = "#F2DDDD";
        elevation_3       = "#EDD0D0";
        overlay           = "#000000";

        # Text variants
        link              = "#1976D2";
        link_hover        = "#0D47A1";
        placeholder       = "#757575";
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
        crust             = "#0a0908";
        background        = "#0a0908";
        accent_dark       = "#1a1712";
        accent            = "#d4c4a8";
        accent_light      = "#e8dcc8";
        border            = "#3a3028";
        backgroundAccent  = "#1a1712";
        overlay2          = "#242018";
        surface           = "#0f0d08";
        bar              = "#0f0d08";
        divider          = "#3a3028";
        overlay1          = "#242018";
        highlighted       = "#4a4038";
        element_background = "#1a1712";
        ui_error          = "#D4553A";
        ui_warning        = "#E8A040";
        ui_success        = "#7ABA5E";
        ui_info           = "#7AAECE";
        ui_hint           = "#8a7a64";
        ui_match          = "#F0B040";
        text              = "#e8dcc8";
        subtext0          = "#c4b49a";
        subtext1          = "#8a7a64";
        cursor            = "#d4c4a8";
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

        # Interactive states
        interactive       = "#4a4038";
        interactive_hover = "#5a5048";
        interactive_pressed = "#3a3028";
        interactive_disabled = "#242018";
        focus             = "#5a5048";

        # Input/form states
        input_background  = "#1a1712";
        input_border      = "#3a3028";
        input_border_focus = "#d4c4a8";

        # Status indicators
        status_active     = "#7ABA5E";
        status_inactive   = "#242018";
        status_syncing    = "#7AAECE";
        status_processing = "#E8A040";

        # Transfer/progress
        transfer_send     = "#4A7C9A";
        transfer_receive  = "#9ABA5E";
        transfer_complete = "#7ABA5E";
        transfer_failed   = "#D4553A";

        # Audio
        audio_waveform    = "#c4b49a";
        audio_active      = "#9ABA5E";

        # Syntax/code
        syntax_keyword    = "#B07AAA";
        syntax_string     = "#9ABA5E";
        syntax_number     = "#F0A850";
        syntax_comment    = "#8a7a64";
        syntax_function   = "#4A7C9A";
        syntax_variable   = "#e8dcc8";

        # Charts/data
        chart_1           = "#E86A4A";
        chart_2           = "#9ABA5E";
        chart_3           = "#F0C040";
        chart_4           = "#4A7C9A";
        chart_5           = "#E07A9A";
        chart_6           = "#6ABAAA";
        chart_grid        = "#242018";

        # Depth/elevation
        elevation_1       = "#1a1712";
        elevation_2       = "#242018";
        elevation_3       = "#3a3028";
        overlay           = "#0a0908";

        # Text variants
        link              = "#7AAECE";
        link_hover        = "#9AC0E0";
        placeholder       = "#8a7a64";
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
