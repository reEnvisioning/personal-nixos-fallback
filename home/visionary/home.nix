{ pkgs, lib, username, unstable, ... }:
{
  home = {
    stateVersion = "26.05";
    username = username;
    homeDirectory = "/home/${username}";
  };

  home.activation.createSshControlDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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

  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      format = "\${custom.host_root}\${custom.host}$directory$git_branch\${custom.git_clean}$git_status$line_break$character";
      custom.host_root = {
        command = "hostname";
        when = ''[ "$(id -u)" = 0 ]'';
        format = "[$output]($style) ";
        style = "bold red";
      };
      custom.host = {
        command = "hostname";
        when = ''[ "$(id -u)" != 0 ]'';
        format = "[$output]($style) ";
        style = "bold cyan";
      };
      custom.git_clean = {
        command = "echo ✓";
        when = ''git rev-parse --is-inside-work-tree >/dev/null 2>&1 && test -z "$(git status --porcelain)"'';
        format = "[$output]($style) ";
        style = "bold green";
      };
      directory = {
        truncation_length = 4;
        truncate_to_repo = false;
        format = "[$path]($style) ";
      };
      git_branch = {
        format = "[$branch]($style)";
        style = "bold purple";
      };
      git_status = {
        format = "([ $all_status$ahead_behind]($style)) ";
        conflicted = "=";
        ahead = "⇡";
        behind = "⇣";
        diverged = "⇕";
        untracked = "?";
        stashed = "$";
        modified = "!";
        staged = "+";
        renamed = "»";
        deleted = "✘";
        style = "bold red";
      };
      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[>](bold red)";
      };
    };
  };

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
