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
}
