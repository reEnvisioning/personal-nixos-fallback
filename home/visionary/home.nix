{ pkgs, lib, username, unstable, ... }:
{
  home = {
    stateVersion = "26.05";
    username = username;
    homeDirectory = "/home/${username}";
  };

  home.activation.createSshControlDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p /home/${username}/.ssh/control
    chmod 700 /home/${username}/.ssh/control
  '';

  programs.git = {
    enable = true;
    includes = [
      { path = "~/.config/reEnvisioning/usr/apps/gitconfig"; }
    ];
    settings.user.useConfigOnly = true;
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
