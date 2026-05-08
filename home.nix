{ config, pkgs, inputs, ... }:
let theme = import ./theme.nix;
in {
    home = {
        stateVersion = "25.11";
        username = "visionary";
        homeDirectory = "/home/visionary";
    };

    programs.home-manager.enable = true;

    home.packages = with pkgs; [
        neovim
        mpv
        feh
        nautilus
        adw-gtk3
    ];

    wayland.windowManager.hyprland = {
        package = pkgs.hyprland;
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
                    "SUPER, C, exec, walker --clipboard"
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
                    "SUPER, space, exec, walker" # app launcher
                    "SUPER, E, exec, nautilus" # file manager
                    "SUPER SHIFT, Q, exec, kitty -e nvim" # neovim
                    "SUPER, B, exec, firefox" # browser
                    # screenshots
                    ", Print, exec, sh -c 'hyprshot --mode region --freeze --output-folder /home/visionary/Pictures'"
                    "SUPER, Print, exec, sh -c 'hyprshot --mode region --freeze --clipboard-only'"
                    # audio controls
                    "SUPER, XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
                    "SUPER, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
                    "SUPER, XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
                    "SUPER, XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
                    # exit
                    "SUPER SHIFT, L, exit" # exit hyprland
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
                env = XCURSOR_THEME,default
                env = XCURSOR_SIZE,24
            '';
        };
    };

    programs.kitty = {
        enable = true;
        settings = {
            background = "${theme.colors.bg}";
            foreground = "${theme.colors.fg}";
            cursor = "${theme.colors.fg}";
            selection_background = "${theme.colors.accent}";
            selection_foreground = "${theme.colors.bg}";
            font_family = "Monospace";
            font_size = 10.0;
        };
        extraConfig = ''
            color1 ${theme.colors.accent3} # Replaces red
            color2 ${theme.colors.accent2} # Replaces green
        '';
    };

    services.dunst = {
        enable = true;
        settings = {
            global = {
                font = "Monospace 10";
                background = "${theme.colors.bg}";
                foreground = "${theme.colors.fg}";
                frame_color = "${theme.colors.accent}";
                frame_width = 2;
            };
            urgency_low = {
                background = "${theme.colors.bg}";
                foreground = "${theme.colors.fg}";
            };
            urgency_normal = {
                background = "${theme.colors.bg}";
                foreground = "${theme.colors.fg}";
            };
            urgency_critical = {
                background = "${theme.colors.accent}";
                foreground = "${theme.colors.fg}";
            };
        };
    };

    gtk = {
        enable = true;
        theme.name = "adw-gtk3-dark";
        theme.package = pkgs.adw-gtk3;
        gtk4.theme = null;
        iconTheme.name = "Adwaita";
        gtk3.extraConfig = { "gtk-application-prefer-dark-theme" = 1; };
        gtk4.extraConfig = { "gtk-application-prefer-dark-theme" = 1; };
        gtk3.extraCss = ''
            * { background-color: ${theme.colors.bg}; color: ${theme.colors.fg}; }
        '';
        gtk4.extraCss = ''
            @define-color window_bg_color ${theme.colors.bg};
            @define-color view_bg_color ${theme.colors.bg};
            @define-color headerbar_bg_color ${theme.colors.bg};
            @define-color card_bg_color ${theme.colors.bg};

            /* Force sidebar accent color */
            .sidebar-pane,
            .nautilus-window .sidebar-pane,
            placessidebar,
            navsidebar {
                background-color: ${theme.colors.accent} !important;
            }
        '';
    };

    dconf = {
        enable = true;
        settings = {
            "org/gnome/desktop/interface" = {
                color-scheme = "prefer-dark";
            };
        };
    };

    xdg.configFile."gtk-4.0/style-dark.css".text = ''
        /* Force OLED black for Libadwaita apps like Nautilus */
        @define-color window_bg_color ${theme.colors.bg};
        @define-color view_bg_color ${theme.colors.bg};
        @define-color headerbar_bg_color ${theme.colors.bg};
        @define-color card_bg_color ${theme.colors.bg};
        @define-color popover_bg_color ${theme.colors.bg};
        @define-color sidebar_bg_color ${theme.colors.accent};
        @define-color content_view_bg_color ${theme.colors.bg};
    '';

    programs.firefox = {
        enable = true;
        profiles.default = {
            settings = {
                "ui.systemUsesDarkTheme" = 1;
                "browser.theme.toolbar-theme" = 1;
                "browser.theme.content-theme" = 1;
            };
        };
    };

    services.hyprpaper = {
        enable = true;
        settings = {
            splash = false;
            preload = [ "/headspace/wallpaper/wallpaper.png" ];
            wallpaper = [
                {
                    monitor = "";
                    path = "/headspace/wallpaper/wallpaper.png";
                    fit_mode = "cover";
                }
            ];
        };
    };
}
