{ config, pkgs, inputs, lib, username, ... }: {
  home = {
    stateVersion = "25.11";
    username = username;
    homeDirectory = "/home/${username}";
  };

  programs.home-manager.enable = true;

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
