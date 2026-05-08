{ pkgs, ... }:
let theme = import ./theme.nix;
in {
    wayland.windowManager.hyprland = {
        enable = true;
        xwayland.enable = true;
        systemd.enable = true;

        settings = {
            general = {
                layout = "dwindle";
                allow_tearing = false;
                border_size = 1;
                gaps_in = 2;
                gaps_out = 2;
                "col.active_border" = "0xff${theme.colors.borderFocusedHex}";
                "col.inactive_border" = "0xff${theme.colors.borderInactiveHex}";
            };

            misc = {
                disable_splash_rendering = true;
            };

            decoration = {
                active_opacity = 0.8;
                inactive_opacity = 0.65;
            };

            monitor = [
                ",1920x1080@144,auto,1"
            ];
            dwindle.preserve_split = "yes";

            input = {
                kb_layout = "us";
                kb_variant = "";
                kb_model = "";
                kb_options = "";
                kb_rules = "";

                numlock_by_default = true;
                repeat_delay = 250;
                repeat_rate = 25;

                follow_mouse = 1;
                mouse_refocus = 0;

                touchpad.natural_scroll = false;
                sensitivity = 0;
                accel_profile = "flat";
            };

            bind = [
                    # essential keybinds
                    "SUPER, W, killactive"
                    "SUPER, V, togglefloating"
                    "SUPER, F, fullscreen"
                    "SUPER, S, togglesplit"
                    "SUPER, P, pin"
                    # move focus with vim-like keybinds
                    "SUPER, h, movefocus, l"
                    "SUPER, j, movefocus, d"
                    "SUPER, k, movefocus, u"
                    "SUPER, l, movefocus, r"
                    # move clients with vim-like keybinds
                    "SUPER SHIFT, h, movewindow, l"
                    "SUPER SHIFT, j, movewindow, d"
                    "SUPER SHIFT, k, movewindow, u"
                    "SUPER SHIFT, l, movewindow, r"
                    # programs
                    "SUPER, return, exec, kitty" # terminal
                    "SUPER, Q, exec, kitty" # terminal
                    "SUPER, E, exec, kitty -e yazi" # file manager
                    "SUPER, B, exec, firefox" # browser
                    "SUPER SHIFT, Q, exec, kitty -e nvim" # neovim
                    # screenshots
                    ", Print, exec, sh -c 'hyprshot --mode region --freeze --output-folder /home/visionary/Pictures'"
                    "SUPER, Print, exec, sh -c 'hyprshot --mode region --freeze --clipboard-only'"
                    # audio controls
                    "SUPER, XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
                    "SUPER, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
                    "SUPER, XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
                    "SUPER, XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
                    # exit
                    "SUPER SHIFT, P, exit" # exit hyprland
                ]
                ++ (builtins.concatLists (builtins.genList (
                        x: let
                            ws = let c = (x + 1) / 10; in builtins.toString (x + 1 - (c * 10));
                        in [
                            "SUPER, ${ws}, workspace, ${toString (x + 1)}"
                            "SUPER Shift, ${ws}, movetoworkspace, ${toString (x + 1)}"
                        ]
                    )
                    10));

            bindm = [
                # Move/resize windows with mainMod + LMB/RMB and dragging
                "SUPER, mouse:272, movewindow"
                "SUPER, mouse:273, resizewindow"
            ];

            animations = [
                "border, 0"
                "fade, 0"
                "windows, 0"
                "windowsOut, 0"
                "windowsMove, 0"
                "workspaces, 0"
                "layers, 0"
                "layersOut, 0"
                "fadeIn, 0"
                "fadeOut, 0"
                "fadeSwitch, 0"
                "fadeShadow, 0"
                "fadeDim, 0"
                "fadeLayers, 0"
                "fadeLayersIn, 0"
                "fadeLayersOut, 0"
                "fadePopups, 0"
                "fadePopupsIn, 0"
                "fadePopupsOut, 0"
                "zoomFactor, 0"
                "monitorAdded, 0"
            ];

            "exec-once" = [
                "hyprpaper"
            ];

            extraConfig = ''
                env = XCURSOR_THEME,Vanilla-DMZ
                env = XCURSOR_SIZE,24
            '';
        };
    };

    services.hyprpaper = {
        enable = true;
        settings = {
            splash = false;
            preload = [ "${theme.wallpaper}" ];
            wallpaper = [
                {
                    monitor = "";
                    path = "${theme.wallpaper}";
                    fit_mode = "cover";
                }
            ];
        };
    };
}
