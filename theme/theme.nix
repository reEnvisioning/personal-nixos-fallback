let
  default = "sakura";

  mkCatppuccin = variant: accent: {
    package = "catppuccin";
    inherit variant accent;
    size = "standard";
    tweaks = [ ];
    themeName = "Catppuccin-${variant}-Standard-${accent}-Dark";
  };

  mkCatppuccinLight = variant: accent: {
    package = "catppuccin";
    inherit variant accent;
    size = "standard";
    tweaks = [ ];
    themeName = "Catppuccin-${variant}-Standard-${accent}";
  };

  allThemes = {
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
        # Accents
        accent_dark = "#F5DCDC";
        accent = "#F0CECE";
        accent_light = "#EBBDBD";

        # Areas
        crust = "#FFF0F0";
        background = "#FFF5F5";
        backgroundAccent = "#F5E0E0";
        surface = "#F5DADA";
        overlay1 = "#EDD0D0";
        overlay2 = "#F2DDDD";
        bar = "#F5DADA";
        element_background = "#FFF0F0";

        # Lines
        border = "#E8C0C0";
        divider = "#E8C0C0";

        # UI
        ui_error = "#D32F2F";
        ui_warning = "#E65100";
        ui_success = "#388E3C";
        ui_info = "#1976D2";
        ui_hint = "#757575";
        ui_match = "#F57C00";

        # Colors
        red = "#D64545";
        blue = "#42A5F5";
        sapphire = "#0277BD";
        maroon = "#C62828";
        mauve = "#7B1FA2";
        lavender = "#7E57C2";
        peach = "#E65100";
        sky = "#0288D1";
        green = "#43A047";
        cyan = "#00838F";
        pink = "#E05A77";
        magenta = "#E91E63";
        flamingo = "#CC7A7A";
        yellow = "#D4A017";
        rosewater = "#D46A7A";

        # Text variants
        text = "#2D2D2D";
        subtext0 = "#757575";
        subtext1 = "#616161";
        cursor = "#F0CECE";
        link = "#1976D2";
        link_hover = "#0D47A1";
        placeholder = "#757575";
        highlighted = "#F5DADA";

        # Syntax/code
        syntax_keyword = "#7B1FA2";
        syntax_string = "#43A047";
        syntax_number = "#E65100";
        syntax_comment = "#757575";
        syntax_function = "#42A5F5";
        syntax_variable = "#2D2D2D";

        # Interactive states
        interactive = "#D08080";
        interactive_hover = "#C06060";
        interactive_pressed = "#E0A0A0";
        interactive_disabled = "#F5DADA";

        # Status indicators
        status_active = "#388E3C";
        status_inactive = "#F5DADA";
        status_syncing = "#1976D2";
        status_processing = "#E65100";

        # Transfer/progress
        transfer_send = "#42A5F5";
        transfer_receive = "#43A047";
        transfer_complete = "#388E3C";
        transfer_failed = "#D32F2F";

        # Audio
        audio_waveform = "#CC7A7A";
        audio_active = "#43A047";

        # Charts/data
        chart_1 = "#D64545";
        chart_2 = "#43A047";
        chart_3 = "#D4A017";
        chart_4 = "#42A5F5";
        chart_5 = "#E91E63";
        chart_6 = "#00838F";
        chart_grid = "#EDD0D0";

        # Depth/elevation
        elevation_1 = "#F5E0E0";
        elevation_2 = "#F2DDDD";
        elevation_3 = "#EDD0D0";
        overlay = "#000000";
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
        # Accents
        accent_dark = "#1a1712";
        accent = "#d4c4a8";
        accent_light = "#e8dcc8";

        # Areas
        crust = "#0a0908";
        background = "#0a0908";
        backgroundAccent = "#1a1712";
        surface = "#0f0d08";
        overlay1 = "#242018";
        overlay2 = "#242018";
        bar = "#0f0d08";
        element_background = "#1a1712";

        # Lines
        border = "#3a3028";
        divider = "#3a3028";

        # UI
        ui_error = "#D4553A";
        ui_warning = "#E8A040";
        ui_success = "#7ABA5E";
        ui_info = "#7AAECE";
        ui_hint = "#8a7a64";
        ui_match = "#F0B040";

        # Colors
        red = "#E86A4A";
        blue = "#4A7C9A";
        sapphire = "#6A9AAA";
        maroon = "#B84A3A";
        mauve = "#B07AAA";
        lavender = "#9A8ABA";
        peach = "#F0A850";
        sky = "#7AAABA";
        green = "#9ABA5E";
        cyan = "#6ABAAA";
        pink = "#E08A9A";
        magenta = "#E07A9A";
        flamingo = "#D0806A";
        yellow = "#F0C040";
        rosewater = "#E0A080";

        # Text variants
        text = "#e8dcc8";
        subtext0 = "#c4b49a";
        subtext1 = "#8a7a64";
        cursor = "#d4c4a8";
        link = "#7AAECE";
        link_hover = "#9AC0E0";
        placeholder = "#8a7a64";
        highlighted = "#4a4038";

        # Syntax/code
        syntax_keyword = "#B07AAA";
        syntax_string = "#9ABA5E";
        syntax_number = "#F0A850";
        syntax_comment = "#8a7a64";
        syntax_function = "#4A7C9A";
        syntax_variable = "#e8dcc8";

        # Interactive states
        interactive = "#4a4038";
        interactive_hover = "#5a5048";
        interactive_pressed = "#3a3028";
        interactive_disabled = "#242018";

        # Status indicators
        status_active = "#7ABA5E";
        status_inactive = "#242018";
        status_syncing = "#7AAECE";
        status_processing = "#E8A040";

        # Transfer/progress
        transfer_send = "#4A7C9A";
        transfer_receive = "#9ABA5E";
        transfer_complete = "#7ABA5E";
        transfer_failed = "#D4553A";

        # Audio
        audio_waveform = "#c4b49a";
        audio_active = "#9ABA5E";

        # Charts/data
        chart_1 = "#E86A4A";
        chart_2 = "#9ABA5E";
        chart_3 = "#F0C040";
        chart_4 = "#4A7C9A";
        chart_5 = "#E07A9A";
        chart_6 = "#6ABAAA";
        chart_grid = "#242018";

        # Depth/elevation
        elevation_1 = "#1a1712";
        elevation_2 = "#242018";
        elevation_3 = "#3a3028";
        overlay = "#0a0908";
      };
    };
  };
in
{
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
