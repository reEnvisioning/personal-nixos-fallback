{ pkgs, hostname, ... }:
let
  theme = import ../../theme/theme.nix;
  hw = import ../../hardware/hardware.nix;
  mod = "Mod";

  wsBinds = builtins.concatLists (builtins.genList (x:
    let wsNum = x + 1; wsKey = if wsNum == 10 then "0" else builtins.toString wsNum; wsStr = builtins.toString wsNum; in [
      ''        "${mod}+${wsKey}" hotkey-overlay-title="Focus workspace ${wsStr}" { focus-workspace ${wsStr}; }''
      ''        "${mod}+Shift+${wsKey}" hotkey-overlay-title="Move window to workspace ${wsStr}" { move-window-to-workspace ${wsStr}; }''
      ''        "${mod}+Ctrl+${wsKey}" hotkey-overlay-title="Move column to workspace ${wsStr}" { move-column-to-workspace ${wsStr}; }''
    ]
  ) 10);
in {
  xdg.configFile."niri/config.kdl".text = ''
    prefer-no-csd

    input {
        keyboard {
            xkb {
                layout "us"
                options "caps:swapescape,altwin:menu_win"
            }
            repeat-delay 200
            repeat-rate 40
        }
        touchpad {
            tap
            natural-scroll
            accel-profile "flat"
        }

        mouse {
            accel-profile "flat"
        }

        focus-follows-mouse max-scroll-amount="0%"
    }

    hotkey-overlay {
        skip-at-startup
    }

    ${hw.niriOutputs}

    window-rule {
        match is-focused=true
        opacity 0.9
    }

    window-rule {
        match is-focused=false
        opacity 0.85
    }

    window-rule {
        match app-id="Minecraft"
        open-maximized true
        opacity 1.0
    }

    window-rule {
        match app-id="firefox" title="YouTube"
        opacity 1.0
    }

    window-rule {
        geometry-corner-radius 8
        clip-to-geometry true
    }

    window-rule {
        match app-id="kitty" title="fzf"
        open-floating true
        default-column-width { proportion 0.4; }
        min-height 300
        max-height 300
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
        // Hotkey overlay
        "Mod+Shift+Slash" hotkey-overlay-title="Show hotkey overlay" { show-hotkey-overlay; }
        "Mod+Alt+T" hotkey-overlay-title="Terminal" { spawn "kitty"; }

        "Mod+Q" hotkey-overlay-title="Close window" { close-window; }
        "Mod+Shift+F" hotkey-overlay-title="Fullscreen window" { fullscreen-window; }
        "Mod+F" hotkey-overlay-title="Maximize column" { maximize-column; }

        // Focus navigation
        "Mod+H" hotkey-overlay-title="Focus column left" { focus-column-left; }
        "Mod+J" hotkey-overlay-title="Focus window down" { focus-window-down; }
        "Mod+K" hotkey-overlay-title="Focus window up" { focus-window-up; }
        "Mod+L" hotkey-overlay-title="Focus column right" { focus-column-right; }
        "Mod+Left" hotkey-overlay-title="Focus column left" { focus-column-left; }
        "Mod+Down" hotkey-overlay-title="Focus window down" { focus-window-down; }
        "Mod+Up" hotkey-overlay-title="Focus window up" { focus-window-up; }
        "Mod+Right" hotkey-overlay-title="Focus column right" { focus-column-right; }

        // Move window/column
        "Mod+Shift+H" hotkey-overlay-title="Move column left" { move-column-left; }
        "Mod+Shift+J" hotkey-overlay-title="Move window down" { move-window-down; }
        "Mod+Shift+K" hotkey-overlay-title="Move window up" { move-window-up; }
        "Mod+Shift+L" hotkey-overlay-title="Move column right" { move-column-right; }
        "Mod+Ctrl+H" hotkey-overlay-title="Move column left" { move-column-left; }
        "Mod+Ctrl+J" hotkey-overlay-title="Move window down" { move-window-down; }
        "Mod+Ctrl+K" hotkey-overlay-title="Move window up" { move-window-up; }
        "Mod+Ctrl+L" hotkey-overlay-title="Move column right" { move-column-right; }
        "Mod+Ctrl+Left" hotkey-overlay-title="Move column left" { move-column-left; }
        "Mod+Ctrl+Down" hotkey-overlay-title="Move window down" { move-window-down; }
        "Mod+Ctrl+Up" hotkey-overlay-title="Move window up" { move-window-up; }
        "Mod+Ctrl+Right" hotkey-overlay-title="Move column right" { move-column-right; }

        // Screenshots
        "Print" hotkey-overlay-title="Screenshot region" { spawn-sh "hyprshot --mode region --freeze --output-folder $HOME/Pictures"; }
        "Mod+Print" hotkey-overlay-title="Screenshot region to clipboard" { spawn-sh "hyprshot --mode region --freeze --clipboard-only"; }

        // App launchers
        "Mod+W" hotkey-overlay-title="Terminal" { spawn "kitty"; }
        "Mod+E" hotkey-overlay-title="File manager" { spawn "kitty" "-e" "yazi"; }
        "Mod+B" hotkey-overlay-title="Browser" { spawn "firefox"; }
        "Mod+Shift+W" hotkey-overlay-title="Neovim" { spawn "kitty" "-e" "nvim"; }
        "Mod+Shift+G" hotkey-overlay-title="GIMP" { spawn "gimp"; }
        "Mod+Shift+B" hotkey-overlay-title="Bluetooth" { spawn "blueman-manager"; }
        "Mod+Shift+N" hotkey-overlay-title="Audio" { spawn "pavucontrol"; }

        // Brightness, volume, mic
        "F13" hotkey-overlay-title="Brightness down" { spawn "brightness" "down"; }
        "F14" hotkey-overlay-title="Brightness up" { spawn "brightness" "up"; }
        "F24" hotkey-overlay-title="Volume up" { spawn "volume" "up"; }
        "F23" hotkey-overlay-title="Volume down" { spawn "volume" "down"; }
        "Mod+Alt+M" hotkey-overlay-title="Toggle volume" { spawn "volume" "toggle"; }
        "Mod+Shift+M" hotkey-overlay-title="Toggle mic" { spawn "mic" "toggle"; }

        // Tab trigger
        "Mod+Alt+1" hotkey-overlay-title="Tab trigger 0" { spawn-sh "echo 0 > $XDG_RUNTIME_DIR/${hostname}-tab-trigger"; }
        "Mod+Alt+2" hotkey-overlay-title="Tab trigger 1" { spawn-sh "echo 1 > $XDG_RUNTIME_DIR/${hostname}-tab-trigger"; }
        "Mod+Alt+3" hotkey-overlay-title="Tab trigger 2" { spawn-sh "echo 2 > $XDG_RUNTIME_DIR/${hostname}-tab-trigger"; }

        // Notifications
        "Mod+Alt+N" hotkey-overlay-title="Toggle DND" { spawn "dnd" "toggle"; }
        "Mod+Alt+Backspace" hotkey-overlay-title="Dismiss notification" { spawn-sh "echo 1 > $XDG_RUNTIME_DIR/${hostname}-notif-dismiss"; }

        // System
        "Mod+Space" hotkey-overlay-title="Launcher" { spawn-sh "touch $XDG_RUNTIME_DIR/${hostname}-launcher-toggle"; }
        "Mod+V" hotkey-overlay-title="Toggle clipboard" { spawn-sh "f=$XDG_RUNTIME_DIR/${hostname}-clip-toggle; v=$(cat $f 2>/dev/null || echo 0); echo $((1 - v)) > $f"; }
        "Mod+Shift+O" hotkey-overlay-title="Lock screen" { spawn "swaylock" "-f"; }
        "Mod+Shift+I" hotkey-overlay-title="Toggle idle" { spawn "idle-toggle" "toggle"; }
        "Mod+Shift+P" hotkey-overlay-title="Quit" { quit; }
        "Mod+Shift+E" hotkey-overlay-title="Quit" { quit; }

        // ---------------------------------------------------------------
        // Window management (behavior)
        // ---------------------------------------------------------------
        "Mod+C" hotkey-overlay-title="Center column" { center-column; }
        "Mod+Ctrl+C" hotkey-overlay-title="Center visible columns" { center-visible-columns; }
        "Mod+Z" hotkey-overlay-title="Toggle floating" { toggle-window-floating; }
        "Mod+Ctrl+Z" hotkey-overlay-title="Switch focus tiling/floating" { switch-focus-between-floating-and-tiling; }
        "Mod+T" hotkey-overlay-title="Toggle tabbed display" { toggle-column-tabbed-display; }
        "Mod+BracketLeft" hotkey-overlay-title="Consume/expel left" { consume-or-expel-window-left; }
        "Mod+BracketRight" hotkey-overlay-title="Consume/expel right" { consume-or-expel-window-right; }
        "Mod+Comma" hotkey-overlay-title="Consume window into column" { consume-window-into-column; }
        "Mod+Period" hotkey-overlay-title="Expel window from column" { expel-window-from-column; }

        // ---------------------------------------------------------------
        // Window management (sizes)
        // ---------------------------------------------------------------
        "Mod+Ctrl+F" hotkey-overlay-title="Expand column width" { expand-column-to-available-width; }
        "Mod+R" hotkey-overlay-title="Cycle preset widths" { switch-preset-column-width; }
        "Mod+Shift+R" hotkey-overlay-title="Cycle preset heights" { switch-preset-window-height; }
        "Mod+Ctrl+R" hotkey-overlay-title="Reset window height" { reset-window-height; }
        "Mod+Equal" hotkey-overlay-title="Increase column width" { set-column-width "+10%"; }
        "Mod+Minus" hotkey-overlay-title="Decrease column width" { set-column-width "-10%"; }
        "Mod+Shift+Equal" hotkey-overlay-title="Increase window height" { set-window-height "+10%"; }
        "Mod+Shift+Minus" hotkey-overlay-title="Decrease window height" { set-window-height "-10%"; }

        // ---------------------------------------------------------------
        // Focus / navigation extras
        // ---------------------------------------------------------------
        "Mod+I" hotkey-overlay-title="Focus previous window" { focus-window-previous; }
        "Mod+G" hotkey-overlay-title="Focus first column" { focus-column-first; }
        "Mod+SemiColon" hotkey-overlay-title="Focus last column" { focus-column-last; }
        "Mod+Ctrl+G" hotkey-overlay-title="Move column to first" { move-column-to-first; }
        "Mod+Ctrl+SemiColon" hotkey-overlay-title="Move column to last" { move-column-to-last; }
        "Mod+Home" hotkey-overlay-title="Focus first column" { focus-column-first; }
        "Mod+End" hotkey-overlay-title="Focus last column" { focus-column-last; }
        "Mod+Ctrl+Home" hotkey-overlay-title="Move column to first" { move-column-to-first; }
        "Mod+Ctrl+End" hotkey-overlay-title="Move column to last" { move-column-to-last; }

        "Mod+WheelScrollDown" hotkey-overlay-title="Focus column right" { focus-column-right; }
        "Mod+WheelScrollUp" hotkey-overlay-title="Focus column left" { focus-column-left; }
        "Mod+Ctrl+WheelScrollDown" hotkey-overlay-title="Move column right" { move-column-right; }
        "Mod+Ctrl+WheelScrollUp" hotkey-overlay-title="Move column left" { move-column-left; }
        "Mod+WheelScrollRight" hotkey-overlay-title="Focus column right" { focus-column-right; }
        "Mod+WheelScrollLeft" hotkey-overlay-title="Focus column left" { focus-column-left; }
        "Mod+Ctrl+WheelScrollRight" hotkey-overlay-title="Move column right" { move-column-right; }
        "Mod+Ctrl+WheelScrollLeft" hotkey-overlay-title="Move column left" { move-column-left; }

        // ---------------------------------------------------------------
        // Multi-monitor column movement
        // ---------------------------------------------------------------
        "Mod+Ctrl+Shift+Left" hotkey-overlay-title="Move to left monitor" { move-column-to-monitor-left; }
        "Mod+Ctrl+Shift+Down" hotkey-overlay-title="Move to lower monitor" { move-column-to-monitor-down; }
        "Mod+Ctrl+Shift+Up" hotkey-overlay-title="Move to upper monitor" { move-column-to-monitor-up; }
        "Mod+Ctrl+Shift+Right" hotkey-overlay-title="Move to right monitor" { move-column-to-monitor-right; }
        "Mod+Ctrl+Shift+H" hotkey-overlay-title="Move to left monitor" { move-column-to-monitor-left; }
        "Mod+Ctrl+Shift+J" hotkey-overlay-title="Move to lower monitor" { move-column-to-monitor-down; }
        "Mod+Ctrl+Shift+K" hotkey-overlay-title="Move to upper monitor" { move-column-to-monitor-up; }
        "Mod+Ctrl+Shift+L" hotkey-overlay-title="Move to right monitor" { move-column-to-monitor-right; }

        "Mod+MouseBack" hotkey-overlay-title="Focus left monitor" { focus-monitor-left; }
        "Mod+MouseForward" hotkey-overlay-title="Focus right monitor" { focus-monitor-right; }
        "Mod+Ctrl+Shift+MouseBack" hotkey-overlay-title="Move to left monitor" { move-column-to-monitor-left; }
        "Mod+Ctrl+Shift+MouseForward" hotkey-overlay-title="Move to right monitor" { move-column-to-monitor-right; }

        // ---------------------------------------------------------------
        // Workspace binds (prev/next, scroll)
        // ---------------------------------------------------------------
        "Mod+Shift+WheelScrollDown" cooldown-ms=150 hotkey-overlay-title="Focus next workspace" { focus-workspace-down; }
        "Mod+Shift+WheelScrollUp" cooldown-ms=150 hotkey-overlay-title="Focus previous workspace" { focus-workspace-up; }
        "Mod+Ctrl+Shift+WheelScrollDown" cooldown-ms=150 hotkey-overlay-title="Move column to next workspace" { move-column-to-workspace-down; }
        "Mod+Ctrl+Shift+WheelScrollUp" cooldown-ms=150 hotkey-overlay-title="Move column to previous workspace" { move-column-to-workspace-up; }

        "Mod+D" hotkey-overlay-title="Focus next workspace" { focus-workspace-down; }
        "Mod+U" hotkey-overlay-title="Focus previous workspace" { focus-workspace-up; }
        "Mod+Page_Down" hotkey-overlay-title="Focus next workspace" { focus-workspace-down; }
        "Mod+Page_Up" hotkey-overlay-title="Focus previous workspace" { focus-workspace-up; }
        "Mod+Ctrl+D" hotkey-overlay-title="Move column to next workspace" { move-column-to-workspace-down; }
        "Mod+Ctrl+U" hotkey-overlay-title="Move column to previous workspace" { move-column-to-workspace-up; }
        "Mod+Ctrl+Page_Down" hotkey-overlay-title="Move column to next workspace" { move-column-to-workspace-down; }
        "Mod+Ctrl+Page_Up" hotkey-overlay-title="Move column to previous workspace" { move-column-to-workspace-up; }
        "Mod+Shift+D" hotkey-overlay-title="Move workspace down" { move-workspace-down; }
        "Mod+Shift+U" hotkey-overlay-title="Move workspace up" { move-workspace-up; }
        "Mod+Shift+Page_Down" hotkey-overlay-title="Move workspace down" { move-workspace-down; }
        "Mod+Shift+Page_Up" hotkey-overlay-title="Move workspace up" { move-workspace-up; }

        // Numbered workspace binds
        ${builtins.concatStringsSep "\n" wsBinds}
    }

    spawn-sh-at-startup "opensnitch-ui --background"

    spawn-sh-at-startup "echo 0 > $XDG_RUNTIME_DIR/${hostname}-dnd; echo 0 > $XDG_RUNTIME_DIR/${hostname}-notif-dismiss; echo 0 > $XDG_RUNTIME_DIR/${hostname}-clip-toggle; echo 0 > $XDG_RUNTIME_DIR/${hostname}-launcher-toggle; echo 0 > $XDG_RUNTIME_DIR/${hostname}-tab-trigger; sleep 0.5; switch-theme $(state get current-theme || echo void); if [ \"$(state get hypridle)\" != \"disabled\" ]; then sway-audio-idle-inhibit & swayidle -w timeout 300 '${pkgs.swaylock}/bin/swaylock -f' timeout 600 'niri msg action power-off-monitors' resume 'niri msg action power-on-monitors' before-sleep '${pkgs.swaylock}/bin/swaylock -f' & disown; fi; nohup sh -c 'for i in $(seq 1 30); do s=$(cat /tmp/wg-vpn-status 2>/dev/null); case \"$s\" in connected) break;; unreachable) notify-send -a Proxy -u critical \"Proxy Offline\" \"Server unreachable — direct connection active\"; break;; esac; sleep 2; done' >/dev/null 2>&1 &"
  '';

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock;
    settings = {
      ignore-empty-password = true;
      hide-keyboard-layout = true;
      color = "#000000";
      indicator-radius = 50;
      indicator-thickness = 7;

      ring-color         = "#333333";
      ring-clear-color   = "#444444";
      ring-ver-color     = "#555555";
      ring-wrong-color   = "#662222";

      inside-color         = "#111111";
      inside-clear-color   = "#1A1A1A";
      inside-ver-color     = "#222222";
      inside-wrong-color   = "#330000";

      text-color         = "#CCCCCC";
      text-clear-color   = "#BBBBBB";
      text-ver-color     = "#AAAAAA";
      text-wrong-color   = "#CC6666";

      key-hl-color         = "#888888";
      bs-hl-color          = "#444444";
      caps-lock-key-hl-color = "#555555";
      caps-lock-bs-hl-color  = "#333333";
      separator-color      = "#222222";
      line-color           = "#1A1A1A";
      line-ver-color       = "#333333";
      line-wrong-color     = "#442222";
      line-clear-color     = "#222222";
    };
  };

  home.packages = with pkgs; [ sway-audio-idle-inhibit swaybg swayidle ];
}
