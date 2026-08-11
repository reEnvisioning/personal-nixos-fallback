{ pkgs, ... }:
{
  home.pointerCursor = {
    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  stylix.targets.firefox.enable = false;
  stylix.targets.librewolf.enable = false;

  xdg.configFile = {
    "gtk-3.0/gtk.css".force = true;
    "gtk-4.0/gtk.css".force = true;
    "qt5ct/qt5ct.conf".force = true;
    "qt6ct/qt6ct.conf".force = true;
    "yazi/theme.toml".force = true;
  };

  programs.kitty = {
    enable = true;
    settings = {
      font_family = "Monospace";
      font_size = 10;
      background = "#0B0B0B";
      shell = "zsh";
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
