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
    prismlauncher
    localsend
    procps
    gimp
    jetbrains.idea-oss
    kdePackages.kdenlive
    libreoffice-qt
    obs-studio
    davinci-resolve-studio
    ocl-icd
  ];

  services.udiskie = {
    enable = true;
    settings = {
      program_options = {
        file_manager = "yazi";
      };
    };
  };
}
