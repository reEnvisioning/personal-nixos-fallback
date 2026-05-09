{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    settings.yazi = {
      manager = {
        show_hidden = true;
        sort_dir_first = true;
        sort_by = "natural";
      };
      opener = {
        text  = [{ run = ''nvim "$@"''; block = true; }];
        code  = [{ run = ''nvim "$@"''; block = true; }];
        image = [{ run = ''feh "$@"''; }];
        video = [{ run = ''mpv --loop-file "$@"''; }];
        audio = [{ run = ''mpv --loop-file "$@"''; }];
      };
    };
  };
}
