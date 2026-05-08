{ config, pkgs, inputs, ... }:
let theme = import ./theme.nix;
in {
    home = {
        stateVersion = "25.11";
        username = "visionary";
        homeDirectory = "/home/visionary";
    };

    home.pointerCursor = {
        package = pkgs.vanilla-dmz;
        name = "Vanilla-DMZ";
        size = 24;
        gtk.enable = true;
        x11.enable = true;
    };

    programs.home-manager.enable = true;

    home.packages = with pkgs; [
        neovim
        mpv
        feh
        adw-gtk3
        prismlauncher
        adwaita-qt
        adwaita-qt6
    ];

    programs.kitty = {
        enable = true;
        settings = {
            background = "${theme.colors.background}";
            foreground = "${theme.colors.text}";
            cursor = "${theme.colors.text}";
            selection_background = "${theme.colors.highlighted}";
            selection_foreground = "${theme.colors.background}";
            font_family = "${theme.font.family}";
            font_size = 1.0 * theme.font.size;
            confirm_os_window_close = 0;
        };
        extraConfig = ''
            color1 ${theme.colors.red}
            color2 ${theme.colors.green}
            color3 ${theme.colors.yellow}
            color4 ${theme.colors.blue}
            color5 ${theme.colors.magenta}
            color6 ${theme.colors.cyan}
        '';
    };

    services.dunst = {
        enable = true;
        settings = {
            global = {
                font = "${theme.font.family} ${toString theme.font.size}";
                background = "${theme.colors.background}";
                foreground = "${theme.colors.text}";
                frame_color = "${theme.colors.backgroundAccent}";
                frame_width = 2;
            };
            urgency_low = {
                background = "${theme.colors.background}";
                foreground = "${theme.colors.text}";
            };
            urgency_normal = {
                background = "${theme.colors.background}";
                foreground = "${theme.colors.text}";
            };
            urgency_critical = {
                background = "${theme.colors.backgroundAccent}";
                foreground = "${theme.colors.text}";
            };
        };
    };

    gtk = {
        enable = true;
        theme.name = "adw-gtk3-dark";
        theme.package = pkgs.adw-gtk3;
        gtk4.theme = null;
        iconTheme.name = "Adwaita";
        gtk3.extraConfig = { "gtk-application-prefer-dark-theme" = if theme.mode == "dark" then 1 else 0; };
        gtk4.extraConfig = { "gtk-application-prefer-dark-theme" = if theme.mode == "dark" then 1 else 0; };
        # gtk3.extraCss = ''
        #     * { background-color: ${theme.colors.background}; color: ${theme.colors.text}; }
        # '';
        # gtk4.extraCss = ''
        #     @define-color window_bg_color ${theme.colors.background};
        #     @define-color view_bg_color ${theme.colors.background};
        #     @define-color headerbar_bg_color ${theme.colors.background};
        #     @define-color card_bg_color ${theme.colors.background};
        #     @define-color popover_bg_color ${theme.colors.backgroundAccent};
        #     /* Dropdown/popover menus */
        #     popover.background,
        #     popover.background menu,
        #     popover.background .popover {
        #         background-color: ${theme.colors.backgroundAccent} !important;
        #     }
        # '';
    };

    dconf = {
        enable = true;
        settings = {
            "org/gnome/desktop/interface" = {
                color-scheme = if theme.mode == "dark" then "prefer-dark" else "default";
            };
        };
    };

    # xdg.configFile."gtk-4.0/style-dark.css".text = ''
    #     /* Force OLED black for Libadwaita apps like Nautilus */
    #     @define-color window_bg_color ${theme.colors.background};
    #     @define-color view_bg_color ${theme.colors.background};
    #     @define-color headerbar_bg_color ${theme.colors.background};
    #     @define-color card_bg_color ${theme.colors.background};
    #     @define-color popover_bg_color ${theme.colors.backgroundAccent};
    #     @define-color sidebar_bg_color ${theme.colors.backgroundAccent};
    #     @define-color content_view_bg_color ${theme.colors.background};
    # '';

    programs.firefox = {
        enable = true;
        profiles.default = {
            settings = {
                "ui.systemUsesDarkTheme" = if theme.mode == "dark" then 1 else 0;
                "browser.theme.toolbar-theme" = 1;
                "browser.theme.content-theme" = 1;
            };
        };
    };
}
