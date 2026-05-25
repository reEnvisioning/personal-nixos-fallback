{ pkgs, ... }:
let
  theme = import ../theme/theme.nix;
  mod = "Mod";

  wsBinds = builtins.concatLists (builtins.genList (x:
    let wsNum = x + 1; ws = if wsNum == 10 then "0" else builtins.toString wsNum; in [
      ''        "${mod}+${ws}" { focus-workspace ${wsNum}; }''
      ''        "${mod}+Shift+${ws}" { move-window-to-workspace ${wsNum}; }''
    ]
  ) 10);
in {
  xdg.configFile."niri/config.kdl".text = ''
    input {
        keyboard {
            xkb {
                layout "us"
            }
            repeat-delay 250
            repeat-rate 25
        }
        touchpad {
            tap
            disable-while-typing
            click-method "clickfinger"
        }
    }

    layout {
        gaps 2
        focus-ring {
            width 1
            active-color "${theme.colors.borderFocused}"
            inactive-color "${theme.colors.borderInactive}"
        }
        border {
            off
        }
        default-column-width { proportion 0.5; }
    }

    binds {
        "Mod+Shift+Slash" { show-hotkey-overlay; }
        "Mod+T" hotkey-overlay-title="Terminal: kitty" { spawn "kitty"; }

        "Mod+Q" { close-window; }
        "Mod+Shift+F" { fullscreen-window; }
        "Mod+F" { maximize-column; }

        "Mod+H" { focus-column-left; }
        "Mod+J" { focus-window-down; }
        "Mod+K" { focus-window-up; }
        "Mod+L" { focus-column-right; }

        "Mod+Shift+H" { move-column-left; }
        "Mod+Shift+J" { move-window-down; }
        "Mod+Shift+K" { move-window-up; }
        "Mod+Shift+L" { move-column-right; }

        "Print" { spawn-sh "hyprshot --mode region --freeze --output-folder $HOME/Pictures"; }
        "Mod+Print" { spawn-sh "hyprshot --mode region --freeze --clipboard-only"; }

        "Mod+W" { spawn "kitty"; }
        "Mod+E" { spawn "kitty" "-e" "yazi"; }
        "Mod+B" { spawn "firefox"; }
        "Mod+Shift+W" { spawn "kitty" "-e" "nvim"; }
        "Mod+Shift+G" { spawn "gimp"; }
        "Mod+Shift+B" { spawn "blueman-manager"; }
        "Mod+Shift+N" { spawn "pavucontrol"; }

        "F13" { spawn "brightness" "down"; }
        "F14" { spawn "brightness" "up"; }
        "F24" { spawn "volume" "up"; }
        "F23" { spawn "volume" "down"; }
        "Mod+Alt+M" { spawn "volume" "toggle"; }
        "Mod+Shift+M" { spawn "mic" "toggle"; }

        "Mod+Alt+1" { spawn-sh "echo 0 > $XDG_RUNTIME_DIR/headspace-tab-trigger"; }
        "Mod+Alt+2" { spawn-sh "echo 1 > $XDG_RUNTIME_DIR/headspace-tab-trigger"; }
        "Mod+Alt+3" { spawn-sh "echo 2 > $XDG_RUNTIME_DIR/headspace-tab-trigger"; }

        "Mod+Alt+N" { spawn "dnd" "toggle"; }
        "Mod+Alt+Backspace" { spawn-sh "echo 1 > $XDG_RUNTIME_DIR/headspace-notif-dismiss"; }
        "Mod+Space" { spawn-sh "touch $XDG_RUNTIME_DIR/headspace-launcher-toggle"; }
        "Mod+C" { spawn-sh "f=$XDG_RUNTIME_DIR/headspace-clip-toggle; v=$(cat $f 2>/dev/null || echo 0); echo $((1 - v)) > $f"; }

        "Mod+Shift+O" { spawn "swaylock" "-f"; }
        "Mod+I" { spawn "idle-toggle" "toggle"; }

        "Mod+Shift+P" { quit; }
        "Mod+Shift+E" { quit; }

        // workspace binds
        ${builtins.concatStringsSep "\n" wsBinds}
    }

    spawn-at-startup "swayidle" "-w" "timeout" "300" "${pkgs.swaylock-effects}/bin/swaylock -f" "timeout" "600" "niri msg action power-off-monitors" "resume" "niri msg action power-on-monitors" "before-sleep" "${pkgs.swaylock-effects}/bin/swaylock -f"

    spawn-sh-at-startup "echo 0 > $XDG_RUNTIME_DIR/headspace-dnd; echo 0 > $XDG_RUNTIME_DIR/headspace-notif-dismiss; echo 0 > $XDG_RUNTIME_DIR/headspace-clip-toggle; sleep 0.5; switch-theme $(state get current-theme || echo void)"
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

  home.packages = with pkgs; [ swaybg swayidle ];
}
