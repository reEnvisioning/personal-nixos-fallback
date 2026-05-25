{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    withPython3 = true;
    withRuby = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      ripgrep
      fd
      lua-language-server
      pyright
      nil
      nixpkgs-fmt
    ];

    plugins = with pkgs.vimPlugins; [
      nvim-web-devicons
      lualine-nvim
      indent-blankline-nvim
      gitsigns-nvim
      nvim-tree-lua
      plenary-nvim
      telescope-nvim
      telescope-ui-select-nvim
      nvim-autopairs
      comment-nvim
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      luasnip
      cmp_luasnip
      friendly-snippets
    ];
  };

  xdg.configFile."nvim/init.lua".source = config.lib.file.mkOutOfStoreSymlink ../theme/resources/neovim/init.lua;
}
