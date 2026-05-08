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
    ];

    programs.kitty = {
        enable = true;
        settings = {
            background = "${theme.colors.bg}";
            foreground = "${theme.colors.fg}";
            cursor = "${theme.colors.fg}";
            selection_background = "${theme.colors.accent}";
            selection_foreground = "${theme.colors.bg}";
            font_family = "${theme.font.family}";
            font_size = 1.0 * theme.font.size;
            confirm_os_window_close = 0;
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
                font = "${theme.font.family} ${toString theme.font.size}";
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
        gtk3.extraConfig = { "gtk-application-prefer-dark-theme" = if theme.mode == "dark" then 1 else 0; };
        gtk4.extraConfig = { "gtk-application-prefer-dark-theme" = if theme.mode == "dark" then 1 else 0; };
        # gtk3.extraCss = ''
        #     * { background-color: ${theme.colors.bg}; color: ${theme.colors.fg}; }
        # '';
        # gtk4.extraCss = ''
        #     @define-color window_bg_color ${theme.colors.bg};
        #     @define-color view_bg_color ${theme.colors.bg};
        #     @define-color headerbar_bg_color ${theme.colors.bg};
        #     @define-color card_bg_color ${theme.colors.bg};
        #     @define-color popover_bg_color ${theme.colors.accent};

        #     /* Dropdown/popover menus */
        #     popover.background,
        #     popover.background menu,
        #     popover.background .popover {
        #         background-color: ${theme.colors.accent} !important;
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
    #     @define-color window_bg_color ${theme.colors.bg};
    #     @define-color view_bg_color ${theme.colors.bg};
    #     @define-color headerbar_bg_color ${theme.colors.bg};
    #     @define-color card_bg_color ${theme.colors.bg};
    #     @define-color popover_bg_color ${theme.colors.accent};
    #     @define-color sidebar_bg_color ${theme.colors.accent};
    #     @define-color content_view_bg_color ${theme.colors.bg};
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
