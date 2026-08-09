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
        style = "bold fg:#FE8019";
      };
      custom.host = {
        command = "hostname";
        when = ''[ "$(id -u)" != 0 ]'';
        format = "[$output]($style) ";
        style = "bold fg:#B5B0A6";
      };
      custom.git_clean = {
        command = "echo ✓";
        when = ''git rev-parse --is-inside-work-tree >/dev/null 2>&1 && test -z "$(git status --porcelain)"'';
        format = "[$output]($style) ";
        style = "bold fg:#B5B0A6";
      };
      directory = {
        truncation_length = 4;
        truncate_to_repo = false;
        format = "[$path]($style) ";
        style = "fg:#7A7B82";
      };
      git_branch = {
        format = "[$branch]($style)";
        style = "bold fg:#FE8019";
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
        style = "bold fg:#FFCC1B";
      };
      character = {
        success_symbol = "[>](bold fg:#B5B0A6)";
        error_symbol = "[>](bold fg:#FE8019)";
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
