{ pkgs, ... }:
let
  theme = import ./theme.nix;
in {
  programs.yazi = {
    enable = true;
    flavors = {
      "dark"  = ./yazi-themes/dark.toml;
      "light" = ./yazi-themes/light.toml;
    };
    settings = {
      yazi = {
        flavor.use = theme.mode;
        manager = {
          show_hidden = true;
          sort_dir_first = true;
          sort_by = "natural";
        };
        opener = {
          text  = [{ run = ''nvim "$@"''; block = true; }];
          image = [{ run = ''feh "$@"''; }];
          video = [{ run = ''mpv --loop-file "$@"''; }];
          audio = [{ run = ''mpv --loop-file "$@"''; }];
        };
      };
      theme = { };
    };
  };
}
