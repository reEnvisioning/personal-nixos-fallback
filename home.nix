{ config, pkgs, inputs, lib, ... }:
let
  theme = import ./theme.nix;

  mkThemeJson = name: t: builtins.toJSON {
    name = name;
    mode = t.mode;
    localsend_color = t.localsend_color;
    wallpaper = toString t.wallpaper;
    colors = t.colors;
  };

  themeJsonConfigs = builtins.listToAttrs (map (name: {
    name = "headspace/themes/${name}.json";
    value.text = mkThemeJson name theme.all.${name};
  }) (builtins.attrNames theme.all));

  yaziThemeConfigs = builtins.listToAttrs (map (name: {
    name = "headspace/yazi-themes/${name}.toml";
    value.source = theme.all.${name}.yazi;
  }) (builtins.attrNames theme.all));
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
    localsend
    jq
    procps
    (writeShellScriptBin "switch-theme" (builtins.readFile ./switch-theme))
  ];

  xdg.configFile = themeJsonConfigs // yaziThemeConfigs;

  xdg.configFile."kitty/kitty.conf".force = true;
  xdg.configFile."dunst/dunstrc".force = true;

  home.activation.setLocalSendTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    file="$HOME/.local/share/org.localsend.localsend_app/shared_preferences.json"
    mkdir -p "$(dirname "$file")"
    if [ -f "$file" ]; then
      ${pkgs.jq}/bin/jq -c \
        --arg theme '${theme.mode}' \
        --arg color '${theme.localsend_color}' \
        '."flutter.ls_theme" = $theme | ."flutter.ls_color" = $color' "$file" > /tmp/localsend_prefs.json \
        && mv /tmp/localsend_prefs.json "$file"
    else
      echo '{"flutter.ls_theme":"${theme.mode}","flutter.ls_color":"${theme.localsend_color}"}' > "$file"
    fi
  '';

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
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = if theme.mode == "dark" then "prefer-dark" else "default";
      };
    };
  };

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
