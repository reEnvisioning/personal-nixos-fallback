{ pkgs, ... }:
let
  theme = import ./theme.nix;
  themeFile = if theme.mode == "dark" then ./yazi-themes/dark.toml else ./yazi-themes/light.toml;
in {
  programs.yazi = {
    enable = true;
    settings = {
      yazi = {
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
      theme = builtins.fromTOML (builtins.readFile themeFile);
    };
  };
}
