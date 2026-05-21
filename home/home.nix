{ config, pkgs, inputs, lib, ... }: {
  home = {
    stateVersion = "25.11";
    username = "visionary";
    homeDirectory = "/home/visionary";
  };

  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    mpv
    adw-gtk3
    prismlauncher
    adwaita-qt
    adwaita-qt6
    libsForQt5.qt5ct
    kdePackages.qt6ct
    localsend
    jq
    procps
    inotify-tools
    gimp
    jetbrains.idea-oss
    kdenlive
    libreoffice-qt
    obs-studio
    davinci-resolve-studio
    ocl-icd
    (writeShellScriptBin "switch-theme" (builtins.readFile ../theme/switch-theme))
  ];
}
