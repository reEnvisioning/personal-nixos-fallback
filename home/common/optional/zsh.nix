{ config, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    history.share = true;
    initContent = ''
      zle_highlight=('default:fg=#${config.lib.stylix.colors.base07}')

      autoload -Uz add-zsh-hook
      add-zsh-hook preexec '_re_prompt_spacing_preexec'
      _re_prompt_spacing_preexec() { print }

      _re_up_line_or_beginning_search() { fc -RI; zle history-beginning-search-backward }
      _re_down_line_or_beginning_search() { fc -RI; zle history-beginning-search-forward }
      zle -N _re_up_line_or_beginning_search
      zle -N _re_down_line_or_beginning_search
      zmodload zsh/terminfo
      [[ -n ''${terminfo[kcuu1]} ]] && bindkey "''${terminfo[kcuu1]}" _re_up_line_or_beginning_search
      [[ -n ''${terminfo[kcud1]} ]] && bindkey "''${terminfo[kcud1]}" _re_down_line_or_beginning_search
    '';
  };
}
