{ pkgs, ... }:
let theme = import ./theme.nix;
in {
  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        "ui.systemUsesDarkTheme" = if theme.mode == "dark" then 1 else 0;
        "browser.theme.toolbar-theme" = if theme.mode == "dark" then 1 else 0;
        "browser.theme.content-theme" = if theme.mode == "dark" then 1 else 0;
      };
    };
  };
}
