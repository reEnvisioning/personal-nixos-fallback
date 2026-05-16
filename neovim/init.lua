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

local headspace_color_map = {
  background = "base",
  backgroundAccent = "mantle",
  highlighted = "overlay0",
  text = "text",
  borderInactive = "surface0",
  borderFocused = "surface1",
  accent = "mauve",
  accent_light = "lavender",
  accent_dark = "mauve",
  red = "red",
  green = "green",
  yellow = "yellow",
  blue = "blue",
  magenta = "pink",
  cyan = "teal",
}

local function read_headspace_colors()
  local f = io.open("/tmp/headspace-colors.json", "r")
  if not f then return nil end
  local content = f:read("*a")
  f:close()
  local ok, data = pcall(vim.json.decode, content)
  if not ok or type(data) ~= "table" then return nil end
  return data
end

local function build_color_overrides(data)
  if not data or not data.colors then return nil end
  local overrides = {}
  for headspace_key, catppuccin_key in pairs(headspace_color_map) do
    local hex = data.colors[headspace_key]
    if hex and type(hex) == "string" and hex:match("^#") then
      overrides[catppuccin_key] = hex
    end
  end
  return overrides
end

local function apply_theme(data)
  local flavor = "mocha"
  if data and data.mode == "light" then flavor = "latte" end

  local color_overrides = {}
  local overrides = build_color_overrides(data)
  if overrides then
    for k, v in pairs(overrides) do
      color_overrides[k] = v
    end
  end

  for k, _ in pairs(package.loaded) do
    if k:match("^catppuccin") then
      package.loaded[k] = nil
    end
  end

  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end
  vim.g.colors_name = nil

  require("catppuccin").setup({
    flavour = flavor,
    compile = { enabled = false },
    color_overrides = { all = color_overrides },
    integrations = {
      cmp = true,
      gitsigns = true,
      nvimtree = true,
      treesitter = true,
      bufferline = true,
      telescope = { enabled = true },
      indent_blankline = { enabled = true },
      native_lsp = {
        enabled = true,
        underlines = {
          errors = { "undercurl" },
          hints = { "undercurl" },
          warnings = { "undercurl" },
          information = { "undercurl" },
        },
      },
    },
  })

  vim.cmd("colorscheme catppuccin")

  local ok_lualine, lualine = pcall(require, "lualine")
  if ok_lualine then
    lualine.setup { options = { theme = 'catppuccin' } }
  end

  vim.cmd("redraw!")
end

local theme_data = read_headspace_colors()
apply_theme(theme_data)

require('nvim-treesitter.configs').setup {
  highlight = { enable = true },
  indent = { enable = true },
}

require("ibl").setup()
require('gitsigns').setup()
require('nvim-autopairs').setup({})
require('Comment').setup()
require('which-key').setup()

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

require("bufferline").setup {
  options = {
    mode = "buffers",
    diagnostics = "nvim_lsp",
    separator_style = "slant",
    offsets = {
      {
        filetype = "NvimTree",
        text = "File Explorer",
        text_align = "left",
        separator = true,
      },
    },
  },
}

vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>", { silent = true })
vim.keymap.set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { silent = true })
vim.keymap.set("n", "<leader>x", ":bdelete<CR>", { silent = true, desc = "Close Buffer" })

local cmp = require 'cmp'
local luasnip = require 'luasnip'

require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
  },
}

local capabilities = require('cmp_nvim_lsp').default_capabilities()

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

local uv = vim.uv or vim.loop
local watch_path = "/tmp/headspace-colors.json"
local watcher = uv.new_fs_event()
local reload_timer = nil

if watcher and vim.fn.filereadable(watch_path) == 1 then
  watcher:start(watch_path, {}, vim.schedule_wrap(function(err)
    if not err then
      if reload_timer then
        reload_timer:stop()
        reload_timer:close()
      end

      reload_timer = uv.new_timer()
      reload_timer:start(100, 0, vim.schedule_wrap(function()
        local data = read_headspace_colors()
        if data then
          apply_theme(data)
        end
        if reload_timer then
          reload_timer:stop()
          reload_timer:close()
          reload_timer = nil
        end
      end))
    end
  end))
end
