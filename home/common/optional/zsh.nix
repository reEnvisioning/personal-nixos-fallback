{ config, pkgs, ... }:
{
  programs.zsh = {
    shellAliases.nix-shell = "nix-shell --command ${pkgs.zsh}/bin/zsh";
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    history.share = true;
    initContent = ''
      zle_highlight=('default:fg=#${config.lib.stylix.colors.base07}')

      autoload -Uz add-zsh-hook
      add-zsh-hook preexec '_re_prompt_spacing_preexec'
      _re_prompt_spacing_preexec() { print }

      zmodload zsh/terminfo
      [[ -n ''${terminfo[kcuu1]} ]] && bindkey "''${terminfo[kcuu1]}" history-beginning-search-backward
      [[ -n ''${terminfo[kcud1]} ]] && bindkey "''${terminfo[kcud1]}" history-beginning-search-forward
      bindkey '^I' autosuggest-accept
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      format = "\${custom.host_nix_shell}\${custom.host_root}\${custom.host}$directory$git_branch\${custom.git_clean}$git_status$line_break$character";
      custom.host_nix_shell = {
        command = "hostname";
        when = ''[ -n "$IN_NIX_SHELL" ]'';
        format = "[$output]($style) ";
        style = "bold fg:#${config.lib.stylix.colors.base0B}";
      };
      custom.host_root = {
        command = "hostname";
        when = ''[ -z "$IN_NIX_SHELL" ] && [ "$(id -u)" = 0 ]'';
        format = "[$output]($style) ";
        style = "bold fg:#${config.lib.stylix.colors.base07}";
      };
      custom.host = {
        command = "hostname";
        when = ''[ -z "$IN_NIX_SHELL" ] && [ "$(id -u)" != 0 ]'';
        format = "[$output]($style) ";
        style = "bold fg:#${config.lib.stylix.colors.base07}";
      };
      custom.git_clean = {
        command = "echo ✓";
        when = ''git rev-parse --is-inside-work-tree >/dev/null 2>&1 && test -z "$(git status --porcelain)"'';
        format = "[$output]($style) ";
        style = "bold fg:#${config.lib.stylix.colors.base04}";
      };
      directory = {
        truncation_length = 4;
        truncate_to_repo = false;
        format = "[$path]($style) ";
        style = "fg:#${config.lib.stylix.colors.base07}";
      };
      git_branch = {
        format = "[$branch]($style)";
        style = "bold fg:#${config.lib.stylix.colors.base09}";
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
        style = "bold fg:#${config.lib.stylix.colors.base0A}";
      };
      character = {
        success_symbol = "[>](bold fg:#${config.lib.stylix.colors.base04})";
        error_symbol = "[>](bold fg:#${config.lib.stylix.colors.base04})";
      };
    };
  };
}
