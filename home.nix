{
    home = {
        stateVersion = "25.11";
        username = "visionary";
        homeDirectory = "/home/visionary";
    };

    programs.home-manager.enable = true;

    home.packages = with pkgs; [ neovim ];

    wayland.windowManager.hyprland = {
        package = pkgs.hyprland;
        enable = true;
        xwayland.enable = true;

        settings = {
            general = {
                layout = "dwindle";
                allow_tearing = false;
            };
            dwindle.preserve_split = "yes";
            gestures.workspace_swipe = "off";

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
            };

            bind = [
                    # essential keybinds
                    "SUPER, C, killactive"
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
                    "SUPER, B, exec, firefox" # browser
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
        };
    };
}
