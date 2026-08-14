{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    settings = {
      opener = {
        edit = [{ run = ''nvim "$@"''; block = true; for = "unix"; }];
        open = [{ run = ''xdg-open "$@"''; for = "unix"; }];
        gimp = [{ run = ''gimp "$@"''; for = "unix"; }];
        play = [{ run = ''mpv --loop-file "$@"''; orphan = true; for = "unix"; }];
      };
      open = {
        rules = [
          { mime = "text/*"; use = [ "edit" "open" ]; }
          { mime = "image/*"; use = [ "gimp" "edit" ]; }
          { mime = "{audio,video}/*"; use = [ "play" "open" ]; }
          { url = "*"; use = [ "open" "edit" ]; }
        ];
      };
    };
  };
}
