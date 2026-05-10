{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    settings = {
      manager = {
        show_hidden = true;
        sort_dir_first = true;
        sort_by = "natural";
      };
      opener = {
        edit = [{ run = ''nvim "$@"''; block = true; for = "unix"; }];
        open = [{ run = ''feh "$@"''; for = "unix"; }];
        play = [{ run = ''mpv --loop-file "$@"''; orphan = true; for = "unix"; }];
      };
      open = {
        rules = [
          { mime = "text/*"; use = [ "edit" "open" ]; }
          { mime = "image/*"; use = [ "open" "edit" ]; }
          { mime = "{audio,video}/*"; use = [ "play" "open" ]; }
          { url = "*"; use = [ "open" "edit" ]; }
        ];
      };
    };
  };
}
