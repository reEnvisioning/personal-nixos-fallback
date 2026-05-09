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
        edit = [{ run = "nvim %s"; block = true; }];
        open = [{ run = "feh %s"; }];
        play = [{ run = "mpv --loop-file %s"; orphan = true; }];
      };
    };
  };
}
