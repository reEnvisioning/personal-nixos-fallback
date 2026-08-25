{ pkgs, cpuVendor, gpuVendor, pc ? "computer", ... }:
let
  hw = import ../../../hosts/common/core/hardware/hardware.nix { inherit pc cpuVendor gpuVendor; };
  mod = "Mod";

  niri-startup = pkgs.writeShellScript "niri-startup" ''
    temporalshell &
    sway-audio-idle-inhibit &
    swayidle -w \
      timeout 300 'swaylock -f' \
      timeout 600 'niri msg action power-off-monitors' \
      resume 'niri msg action power-on-monitors' \
      before-sleep 'swaylock -f' &
    disown
  '';

  wsBinds = builtins.concatLists (builtins.genList
    (x:
      let wsNum = x + 1; wsKey = if wsNum == 10 then "0" else builtins.toString wsNum; wsStr = builtins.toString wsNum; in [
        ''        "${mod}+${wsKey}" hotkey-overlay-title="Focus workspace ${wsStr}" { focus-workspace ${wsStr}; }''
        ''        "${mod}+Shift+${wsKey}" hotkey-overlay-title="Move window to workspace ${wsStr}" { move-window-to-workspace ${wsStr}; }''
        ''        "${mod}+Ctrl+${wsKey}" hotkey-overlay-title="Move column to workspace ${wsStr}" { move-column-to-workspace ${wsStr}; }''
      ]
    ) 10);
in
{
  xdg.configFile."niri/config.kdl".text = ''
    prefer-no-csd

    input {
        keyboard {
            xkb {
                layout "us"
                options "caps:escape,altwin:menu_win"
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
        match app-id="firefox"
        open-maximized true
    }

    window-rule {
        geometry-corner-radius 16
        clip-to-geometry true
    }

    layout {
        background-color "#1A1714"
        gaps 12
        focus-ring {
            width 0
        }
        border {
            off
        }
        default-column-width { proportion 0.5; }
    }

    overview {
        backdrop-color "#3A342C"
    }

    binds {
        "F16" repeat=false hotkey-overlay-title="Toggle overview" { toggle-overview; }

        "Mod+Q" hotkey-overlay-title="Close window" { close-window; }
        "Mod+Shift+F" hotkey-overlay-title="Fullscreen window" { fullscreen-window; }
        "Mod+F" hotkey-overlay-title="Maximize column" { maximize-column; }

        // Navigation
        "Mod+H" hotkey-overlay-title="Focus column left" { focus-column-left; }
        "Mod+J" hotkey-overlay-title="Focus workspace down" { focus-workspace-down; }
        "Mod+K" hotkey-overlay-title="Focus workspace up" { focus-workspace-up; }
        "Mod+L" hotkey-overlay-title="Focus column right" { focus-column-right; }
        "Mod+Shift+H" hotkey-overlay-title="Move column left" { move-column-left; }
        "Mod+Shift+J" hotkey-overlay-title="Move window to workspace down" { move-window-to-workspace-down; }
        "Mod+Shift+K" hotkey-overlay-title="Move window to workspace up" { move-window-to-workspace-up; }
        "Mod+Shift+L" hotkey-overlay-title="Move column right" { move-column-right; }
        "Mod+Ctrl+J" hotkey-overlay-title="Focus window down" { focus-window-down; }
        "Mod+Ctrl+K" hotkey-overlay-title="Focus window up" { focus-window-up; }
        "Mod+Ctrl+Shift+J" hotkey-overlay-title="Move window down" { move-window-down; }
        "Mod+Ctrl+Shift+K" hotkey-overlay-title="Move window up" { move-window-up; }
        "Mod+Alt+H" hotkey-overlay-title="Focus left monitor" { focus-monitor-left; }
        "Mod+Alt+J" hotkey-overlay-title="Focus lower monitor" { focus-monitor-down; }
        "Mod+Alt+K" hotkey-overlay-title="Focus upper monitor" { focus-monitor-up; }
        "Mod+Alt+L" hotkey-overlay-title="Focus right monitor" { focus-monitor-right; }
        "Mod+Alt+Shift+H" hotkey-overlay-title="Move window to left monitor" { move-window-to-monitor-left; }
        "Mod+Alt+Shift+J" hotkey-overlay-title="Move window to lower monitor" { move-window-to-monitor-down; }
        "Mod+Alt+Shift+K" hotkey-overlay-title="Move window to upper monitor" { move-window-to-monitor-up; }
        "Mod+Alt+Shift+L" hotkey-overlay-title="Move window to right monitor" { move-window-to-monitor-right; }

        // Mouse
        "Mod+WheelScrollUp" cooldown-ms=150 hotkey-overlay-title="Focus column left" { focus-column-left; }
        "Mod+WheelScrollDown" cooldown-ms=150 hotkey-overlay-title="Focus column right" { focus-column-right; }
        "Mod+Shift+WheelScrollUp" cooldown-ms=150 hotkey-overlay-title="Focus workspace up" { focus-workspace-up; }
        "Mod+Shift+WheelScrollDown" cooldown-ms=150 hotkey-overlay-title="Focus workspace down" { focus-workspace-down; }

        // Touchpad
        "Mod+TouchpadScrollUp" cooldown-ms=150 hotkey-overlay-title="Focus column left" { focus-column-left; }
        "Mod+TouchpadScrollDown" cooldown-ms=150 hotkey-overlay-title="Focus column right" { focus-column-right; }
        "Mod+Shift+TouchpadScrollUp" cooldown-ms=150 hotkey-overlay-title="Focus workspace up" { focus-workspace-up; }
        "Mod+Shift+TouchpadScrollDown" cooldown-ms=150 hotkey-overlay-title="Focus workspace down" { focus-workspace-down; }

        // Screenshots
        "Print" hotkey-overlay-title="Screenshot region" { spawn-sh "hyprshot --mode region --freeze --output-folder $HOME/Pictures"; }
        "Mod+Print" hotkey-overlay-title="Screenshot region to clipboard" { spawn-sh "hyprshot --mode region --freeze --clipboard-only"; }

        // App launchers
        "Mod+W" hotkey-overlay-title="Terminal" { spawn "kitty"; }
        "Mod+E" hotkey-overlay-title="File manager" { spawn "kitty" "-e" "yazi"; }
        "Mod+Shift+W" hotkey-overlay-title="Neovim" { spawn "kitty" "-e" "nvim"; }

        // Brightness, volume, mic
        "F13" hotkey-overlay-title="Brightness down" { spawn "brightnessctl" "set" "5%-"; }
        "F14" hotkey-overlay-title="Brightness up" { spawn "brightnessctl" "set" "5%+"; }
        "F24" hotkey-overlay-title="Volume up" { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
        "F23" hotkey-overlay-title="Volume down" { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
        "F22" hotkey-overlay-title="Toggle volume" { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
        "Mod+F10" hotkey-overlay-title="Toggle mic" { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }

        // System
        "F17" hotkey-overlay-title="Lock screen" { spawn "swaylock" "-f"; }
        "Mod+Escape" hotkey-overlay-title="Quit" { quit; }
        "Mod+F6" hotkey-overlay-title="Shut down" { spawn "systemctl" "poweroff"; }
        "Mod+F17" hotkey-overlay-title="Log out" { quit; }

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

        // Navigation extras
        "Mod+I" hotkey-overlay-title="Focus previous window" { focus-window-previous; }
        "Mod+G" hotkey-overlay-title="Focus first column" { focus-column-first; }
        "Mod+SemiColon" hotkey-overlay-title="Focus last column" { focus-column-last; }
        "Mod+Ctrl+G" hotkey-overlay-title="Move column to first" { move-column-to-first; }
        "Mod+Ctrl+SemiColon" hotkey-overlay-title="Move column to last" { move-column-to-last; }

        // Workspace movement
        "Mod+Shift+D" hotkey-overlay-title="Move workspace down" { move-workspace-down; }
        "Mod+Shift+U" hotkey-overlay-title="Move workspace up" { move-workspace-up; }

        // Numbered workspace binds
        ${builtins.concatStringsSep "\n" wsBinds}
    }

    spawn-sh-at-startup "${niri-startup}"
  '';

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock;
    settings = {
      ignore-empty-password = true;
      hide-keyboard-layout = true;
      indicator-radius = 50;
      indicator-thickness = 7;
    };
  };

  home.packages = with pkgs; [ sway-audio-idle-inhibit swaybg swayidle ];
}
