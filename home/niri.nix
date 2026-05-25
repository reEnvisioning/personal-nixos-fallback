{ pkgs, ... }:
let
  theme = import ../theme/theme.nix;
  mod = "Mod";

  # Generate 10 workspace keybinds
  wsBinds = builtins.concatLists (builtins.genList (x:
    let ws = builtins.toString (x + 1); in [
      ''        "${mod}+${ws}" { focus-workspace ${ws}; }''
      ''        "${mod}+Shift+${ws}" { move-column-to-workspace ${ws}; }''
    ]
  ) 10);
in {
  xdg.configFile."niri/config.kdl".text = ''
    input {
        keyboard {
            xkb {
                layout "us"
            }
        }
        touchpad {
            tap true
            disable-while-typing true
            click-method "clickfinger"
        }
    }

    layout {
        gaps 2
        border {
            active-color "${theme.colors.borderFocused}"
            inactive-color "${theme.colors.borderInactive}"
        }
        background-color "${theme.colors.background}"
    }

    monitor "" {
        width 1920
        height 1080
        refresh-rate 144
        scale 1
    }

    binds {
        "Mod+Q" { kill-focused; }
        "Mod+Shift+F" { toggle-window-floating; }
        "Mod+F" { fullscreen-window; }

        "Mod+H" { focus-column-left; }
        "Mod+J" { focus-window-down; }
        "Mod+K" { focus-window-up; }
        "Mod+L" { focus-column-right; }

        "Mod+Shift+H" { move-column-left; }
        "Mod+Shift+J" { move-window-down; }
        "Mod+Shift+K" { move-window-up; }
        "Mod+Shift+L" { move-column-right; }

        "Print" { spawn "sh -c 'hyprshot --mode region --freeze --output-folder ~/Pictures'"; }
        "Mod+Print" { spawn "sh -c 'hyprshot --mode region --freeze --clipboard-only'"; }

        "Mod+W" { spawn "kitty"; }
        "Mod+E" { spawn "kitty -e yazi"; }
        "Mod+B" { spawn "firefox"; }
        "Mod+Shift+W" { spawn "kitty -e nvim"; }
        "Mod+Shift+H" { spawn "localsend_app"; }
        "Mod+Shift+G" { spawn "gimp"; }
        "Mod+Shift+B" { spawn "blueman-manager"; }
        "Mod+Shift+N" { spawn "pavucontrol"; }

        "F13" { spawn "brightness down"; }
        "F14" { spawn "brightness up"; }
        "F24" { spawn "volume up"; }
        "F23" { spawn "volume down"; }
        "Mod+Alt+M" { spawn "volume toggle"; }
        "Mod+Shift+M" { spawn "mic toggle"; }

        "Mod+Alt+1" { spawn "sh -c 'echo 0 > $XDG_RUNTIME_DIR/headspace-tab-trigger'"; }
        "Mod+Alt+2" { spawn "sh -c 'echo 1 > $XDG_RUNTIME_DIR/headspace-tab-trigger'"; }
        "Mod+Alt+3" { spawn "sh -c 'echo 2 > $XDG_RUNTIME_DIR/headspace-tab-trigger'"; }

        "Mod+Alt+N" { spawn "dnd toggle"; }
        "Mod+Alt+Backspace" { spawn "sh -c 'echo 1 > $XDG_RUNTIME_DIR/headspace-notif-dismiss'"; }
        "Mod+Space" { spawn "sh -c 'touch $XDG_RUNTIME_DIR/headspace-launcher-toggle'"; }
        "Mod+C" { spawn "sh -c 'f=$XDG_RUNTIME_DIR/headspace-clip-toggle; v=$(cat $f 2>/dev/null || echo 0); echo $((1 - v)) > $f'"; }

        "Mod+Shift+O" { spawn "${pkgs.swaylock-effects}/bin/swaylock -f"; }
        "Mod+I" { spawn "idle-toggle toggle"; }

        "Mod+Shift+P" { quit; }

        "Mod+mouse:272" { move-window; }
        "Mod+mouse:273" { resize-window; }

        # generated workspace binds
        ${builtins.concatStringsSep "\n" wsBinds}
    }

    spawn-at-startup {
        "/bin/sh -c \"state get hypridle | grep -q disabled && systemctl --user stop swayidle; echo 0 > $XDG_RUNTIME_DIR/headspace-dnd; echo 0 > $XDG_RUNTIME_DIR/headspace-notif-dismiss; echo 0 > $XDG_RUNTIME_DIR/headspace-clip-toggle; sleep 0.5; switch-theme $(state get current-theme || echo void)\""
    }
  '';

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      ignore-empty-password = true;
      hide-keyboard-layout = true;
      fade-in = 0.2;
      image = "${theme.wallpaper}";
      scaling = "fill";
      effect-blur = "7x5";
      indicator-radius = 100;
      indicator-thickness = 7;
      ring-color = "${theme.colors.borderFocused}";
      key-hl-color = "${theme.colors.text}";
      separator-color = "${theme.colors.backgroundAccent}";
      text-color = "${theme.colors.text}";
      line-color = "${theme.colors.background}";
    };
  };

  services.swayidle = {
    enable = true;
    events = [
      {
        timeout = 300;
        command = "${pkgs.swaylock-effects}/bin/swaylock -f";
      }
      {
        before-sleep = "${pkgs.swaylock-effects}/bin/swaylock -f";
      }
    ];
  };

  home.packages = with pkgs; [ swaybg ];
}
