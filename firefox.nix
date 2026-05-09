{ ... }: {
  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        "ui.systemUsesDarkTheme" = 3;
        "browser.theme.toolbar-theme" = 2;
        "browser.theme.content-theme" = 2;
      };
    };
  };
}
