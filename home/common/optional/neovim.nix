{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    withPython3 = true;
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
      blink-cmp
      friendly-snippets
    ];

    initLua = ''
      local undodir = vim.fn.stdpath("state") .. "/undo"
      if vim.fn.isdirectory(undodir) == 0 then
        vim.fn.mkdir(undodir, "p")
      end
      vim.opt.undodir = undodir
      vim.opt.undofile = true

      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.mouse = 'a'
      vim.opt.clipboard = 'unnamedplus'
      vim.opt.breakindent = true
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.termguicolors = true
      vim.opt.signcolumn = 'yes'
      vim.g.mapleader = ' '
      vim.g.maplocalleader = ' '

      require("ibl").setup()
      require('gitsigns').setup()
      require('nvim-autopairs').setup({})
      require('Comment').setup()
      require("nvim-tree").setup({
        filters = { dotfiles = false },
        view = { width = 30 },
      })

      local telescope = require('telescope')
      telescope.setup {
        extensions = {
          ["ui-select"] = { require("telescope.themes").get_dropdown {} },
        },
      }
      pcall(telescope.load_extension, 'ui-select')

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live Grep' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find Buffers' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Find Help' })
      vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { desc = 'Toggle File Explorer' })

      vim.keymap.set("n", "<Tab>", ":bnext<CR>", { silent = true })
      vim.keymap.set("n", "<S-Tab>", ":bprev<CR>", { silent = true })
      vim.keymap.set("n", "<leader>x", ":bdelete<CR>", { silent = true, desc = "Close Buffer" })

      local function has_words_before()
        local col = vim.api.nvim_win_get_cursor(0)[2]
        return col > 0 and not vim.api.nvim_get_current_line():sub(col, col):match('%s')
      end

      local blink = require('blink.cmp')
      blink.setup {
        keymap = {
          preset = 'none',
          ['<Tab>'] = {
            function(cmp)
              if cmp.snippet_active() then return cmp.snippet_forward() end
              if has_words_before() then
                return cmp.select_next({
                  count = cmp.get_selected_item_idx() and 1 or 0,
                  on_ghost_text = true,
                })
              end
            end,
            'fallback',
          },
          ['<S-Tab>'] = { 'snippet_backward', 'insert_prev', 'fallback' },
          ['<C-y>'] = { 'select_and_accept', 'fallback' },
          ['<C-e>'] = { 'cancel', 'fallback' },
        },
        completion = {
          menu = { auto_show = false },
          list = { selection = { preselect = false } },
          ghost_text = { enabled = true, show_without_selection = true },
        },
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
          providers = {
            buffer = {
              opts = { get_bufnrs = function() return { vim.api.nvim_get_current_buf() } end },
            },
          },
        },
        fuzzy = { implementation = 'lua' },
      }
      vim.api.nvim_set_hl(0, 'BlinkCmpGhostText', { link = 'Comment' })

      local capabilities = blink.get_lsp_capabilities()

      local function setup_server(server_name, config)
        local ok, server_config = pcall(require, "lspconfig.server_configurations." .. server_name)
        if not ok then return end

        local default_config = server_config.default_config
        local final_config = vim.tbl_deep_extend("force", default_config, config or {})
        final_config.capabilities = vim.tbl_deep_extend("force", final_config.capabilities or {}, capabilities)

        vim.api.nvim_create_autocmd("FileType", {
          pattern = final_config.filetypes,
          callback = function(args)
            local instance_config = vim.tbl_deep_extend("force", {}, final_config)
            local root_dir = final_config.root_dir
            if type(root_dir) == "function" then
              root_dir = root_dir(args.file)
            end
            instance_config.root_dir = root_dir or vim.fs.dirname(args.file)
            vim.lsp.start(instance_config)
          end,
        })
      end

      setup_server("pyright", {})
      setup_server("nil_ls", {})
      setup_server("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            globals = { 'vim' },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })
    '';
  };
}
