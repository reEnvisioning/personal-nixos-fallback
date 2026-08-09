{ pkgs, ... }:
{
  home.pointerCursor = {
    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  stylix.targets = {
    firefox.profileNames = [ "default" "profile1" "profile2" ];
    librewolf.profileNames = [ "default" ];
  };

  programs.kitty = {
    enable = true;
    settings = {
      font_family = "Monospace";
      font_size = 10;
      confirm_os_window_close = 0;
    };
  };

  programs.btop = {
    enable = true;
    settings = {
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
