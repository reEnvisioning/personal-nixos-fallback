{ config, pkgs, ... }:
{
  home.pointerCursor = {
    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  programs.kitty = {
    enable = true;
    settings = {
      font_family = "Monospace";
      font_size = 10;
      confirm_os_window_close = 0;
    };
    extraConfig = ''
      include ~/.config/kitty/retheme-base16.conf
    '';
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "${config.home.homeDirectory}/.config/btop/themes/retheme-base16.theme";
      theme_background = false;
      truecolor = true;
      rounded_corners = true;
      graph_symbol = "braille";
      shown_boxes = "cpu mem net proc";
      update_ms = 2000;
    };
  };

  gtk = {
    enable = true;
    iconTheme.name = "Adwaita";
  };
}
