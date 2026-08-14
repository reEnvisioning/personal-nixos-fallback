{ pkgs, username, unstable, ... }:
{
  home = {
    stateVersion = "26.05";
    username = username;
    homeDirectory = "/home/${username}";
  };

  programs.git.enable = true;

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    mpv
    prismlauncher
    localsend
    keepassxc
    element-desktop
    protonmail-desktop
    procps
    gimp
    blender
    libreoffice-qt
    obs-studio
    xwayland-satellite
    opencode
    unstable.pi-coding-agent
  ];

  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    settings = {
      program_options = {
        file_manager = "yazi";
      };
    };
  };
}
