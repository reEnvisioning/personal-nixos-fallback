{ pkgs, ... }:
let theme = import ../theme/theme.nix;
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
                "col.active_border" = "0xff${theme.hex theme.colors.borderFocused}";
                "col.inactive_border" = "0xff${theme.hex theme.colors.borderInactive}";
            };

            misc = {
                disable_splash_rendering = true;
            };

            decoration = {
                active_opacity = theme.active_opacity;
                inactive_opacity = theme.inactive_opacity;
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

                touchpad = {
                    natural_scroll = false;
                    tap-to-click = true;
                    disable_while_typing = true;
                    clickfinger_behavior = true;
                    drag_lock = true;
                    scroll_factor = 1.0;
                };
                sensitivity = 0;
                accel_profile = "flat";
            };

            bind = [
                    "SUPER, Q, killactive"
                    "SUPER SHIFT, F, togglefloating"
                    "SUPER, F, fullscreen"
                    "SUPER, T, togglesplit"
                    "SUPER, P, pin"

                    "SUPER, h, movefocus, l"
                    "SUPER, j, movefocus, d"
                    "SUPER, k, movefocus, u"
                    "SUPER, l, movefocus, r"

                    "SUPER SHIFT, j, movewindow, d"
                    "SUPER SHIFT, k, movewindow, u"
                    "SUPER SHIFT, l, movewindow, r"

                    ", Print, exec, sh -c 'hyprshot --mode region --freeze --output-folder ~/Pictures'"
                    "SUPER, Print, exec, sh -c 'hyprshot --mode region --freeze --clipboard-only'"

		    "SUPER, W, exec, kitty"
                    "SUPER, E, exec, kitty -e yazi"
                    "SUPER, B, exec, firefox"
                    "SUPER SHIFT, W, exec, kitty -e nvim"
                    "SUPER SHIFT, H, exec, localsend_app"
                    "SUPER SHIFT, G, exec, gimp"
                    "SUPER SHIFT, B, exec, blueman-manager"
                    "SUPER SHIFT, M, exec, pavucontrol"

                    # brightness
                    ", F13, exec, brightnessctl set 5%-"
                    ", F14, exec, brightnessctl set +5%"
                    # audio controls
                    ", F24, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
                    ", F23, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
                    ", F22, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
                    ", F21, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

                    # tab bar shortcuts
                    "SUPER ALT, 1, exec, sh -c 'echo 0 > $XDG_RUNTIME_DIR/headspace-tab-trigger'"
                    "SUPER ALT, 2, exec, sh -c 'echo 1 > $XDG_RUNTIME_DIR/headspace-tab-trigger'"
                    "SUPER ALT, 3, exec, sh -c 'echo 2 > $XDG_RUNTIME_DIR/headspace-tab-trigger'"

                    # notification: toggle DnD
                    "SUPER ALT, N, exec, sh -c 'f=$XDG_RUNTIME_DIR/headspace-dnd; v=$(cat $f 2>/dev/null || echo 0); echo $((1 - v)) > $f'"

                    # notification: dismiss all
                    "SUPER ALT, Backspace, exec, sh -c 'echo 1 > $XDG_RUNTIME_DIR/headspace-notif-dismiss'"

                    # launcher: Super+Space
                    "SUPER, SPACE, exec, sh -c 'touch $XDG_RUNTIME_DIR/headspace-launcher-toggle'"

                    # clipboard: toggle panel
                    "SUPER, C, exec, sh -c 'f=$XDG_RUNTIME_DIR/headspace-clip-toggle; v=$(cat $f 2>/dev/null || echo 0); echo $((1 - v)) > $f'"

                    "SUPER SHIFT, O, exec, hyprlock"
                    "SUPER SHIFT, P, exit"
                    "SUPER, I, exec, bash -c 'if pgrep -x hypridle >/dev/null; then pkill -x hypridle; else hypridle & fi'"
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

            "exec-once" = [
                "hyprpaper"
                "hypridle"
                "bash -c 'echo 0 > $XDG_RUNTIME_DIR/headspace-dnd && echo 0 > $XDG_RUNTIME_DIR/headspace-notif-dismiss && echo 0 > $XDG_RUNTIME_DIR/headspace-clip-toggle; for i in 1 2 3; do hyprctl hyprpaper reload >/dev/null 2>&1 && break; sleep 0.3; done; switch-theme $(cat ~/.config/headspace/current 2>/dev/null || echo void)'"
            ];
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

    home.packages = with pkgs; [
        hypridle
        hyprlock
    ];

    xdg.configFile."hypr/hypridle.conf".text = ''
        general {
            lock_cmd = hyprlock
            before_sleep_cmd = hyprlock
        }

        listener {
            timeout = 300
            on-timeout = hyprlock
        }
    '';

    xdg.configFile."hypr/hyprlock.conf".text = ''
        general {
            disable_loading_bar = true
            hide_cursor = true
        }

        background {
            monitor =
            path = ${theme.wallpaper}
            blur_passes = 2
            contrast = 0.8
            brightness = 0.5
            vibrancy = 0.2
        }

        input-field {
            monitor =
            size = 200, 50
            position = 0, -80
            dots_center = true
            fade_on_empty = true
            outline_thickness = 2
            dots_size = 0.3
            dots_spacing = 0.5
        }
    '';
}
