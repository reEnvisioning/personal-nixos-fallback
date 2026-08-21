{ config, pkgs, ... }:
{
  programs.zsh = {
    shellAliases.nix-shell = "nix-shell --command ${pkgs.zsh}/bin/zsh";
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    history = {
      share = true;
      ignoreDups = true;
      expireDuplicatesFirst = true;
      ignoreSpace = true;
    };
    initContent = ''
      zle_highlight=('default:fg=#${config.lib.stylix.colors.base07}')

      autoload -Uz add-zsh-hook edit-command-line
      add-zsh-hook preexec '_re_prompt_spacing_preexec'
      _re_prompt_spacing_preexec() { print }

      zle -N edit-command-line
      bindkey '^X^E' edit-command-line

      zstyle ':completion:*' menu select
      _re_tab() {
        if [[ $LASTWIDGET == _re_tab ]]; then
          if (( _re_tab_accepted )); then
            BUFFER=$_re_tab_buffer
            CURSOR=$_re_tab_cursor
            _re_tab_accepted=0
          fi
          zle expand-or-complete
          return
        fi

        _re_tab_buffer=$BUFFER
        _re_tab_cursor=$CURSOR
        zle autosuggest-accept
        if [[ $BUFFER == $_re_tab_buffer && $CURSOR == $_re_tab_cursor ]]; then
          _re_tab_accepted=0
          zle expand-or-complete
        else
          _re_tab_accepted=1
        fi
      }
      zle -N _re_tab
      bindkey '^I' _re_tab

      zmodload zsh/terminfo
      [[ -n ''${terminfo[kcuu1]} ]] && bindkey "''${terminfo[kcuu1]}" history-beginning-search-backward
      [[ -n ''${terminfo[kcud1]} ]] && bindkey "''${terminfo[kcud1]}" history-beginning-search-forward
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
        success_symbol = "[❯](bold fg:#${config.lib.stylix.colors.base04})";
        error_symbol = "[❯](bold fg:#${config.lib.stylix.colors.base04})";
      };
    };
  };
}
