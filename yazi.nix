{ pkgs, ... }:
let
  theme = import ./theme.nix;
  activeFlavor = if theme.mode == "dark" then "oled-dark" else "oled-light";
in {
  programs.yazi = {
    enable = true;
    flavors = {
      "oled-dark" = ./yazi-themes/dark.toml;
      "oled-light" = ./yazi-themes/light.toml;
    };
    settings.yazi = {
      flavor.use = activeFlavor;
      manager.show_hidden = true;
      sort_dir_first = true;
      sort_by = "natural";
    };
    settings.opener = {
      text  = [{ run = ''nvim "$@"''; block = true; }];
      image = [{ run = ''feh "$@"''; }];
      video = [{ run = ''mpv --loop-file "$@"''; }];
      audio = [{ run = ''mpv --loop-file "$@"''; }];
    };
  };
}
