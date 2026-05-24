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
  red = "red",
  green = "green",
  yellow = "yellow",
  blue = "blue",
  magenta = "pink",
  cyan = "teal",
  mauve = "mauve",
  lavender = "lavender",
  pink = "pink",
  rosewater = "rosewater",
  flamingo = "flamingo",
  maroon = "maroon",
  peach = "peach",
  sky = "sky",
  sapphire = "sapphire",
  surface2 = "surface2",
  overlay1 = "overlay1",
  overlay2 = "overlay2",
  crust = "crust",
  subtext0 = "subtext0",
  subtext1 = "subtext1",
}

local function read_headspace_colors()
  local colors_path = (os.getenv("XDG_RUNTIME_DIR") or "/run/user/1000") .. "/headspace-colors.json"
  local f = io.open(colors_path, "r")
  if not f then return nil end
  local content = f:read("*a")
  f:close()
  local ok, data = pcall(vim.json.decode, content)
  if not ok or type(data) ~= "table" then return nil end
  return data
end

local function build_color_overrides(data)
  if not data then return nil end
  local overrides = {}
  for headspace_key, catppuccin_key in pairs(headspace_color_map) do
    local hex = data[headspace_key]
    if hex and type(hex) == "string" and hex:match("^#") then
      overrides[catppuccin_key] = hex
    end
  end
  return overrides
end

local function fix_cmp_highlights(data)
  if not data then return end
  local hl = data.highlighted
  local sel = data.surface2
  local fg = data.text
  if hl and fg then
    vim.api.nvim_set_hl(0, "Pmenu", { bg = hl, fg = fg })
    vim.api.nvim_set_hl(0, "PmenuSbar", { bg = hl })
  end
  if sel and fg then
    vim.api.nvim_set_hl(0, "PmenuSel", { bg = sel, fg = fg })
    vim.api.nvim_set_hl(0, "PmenuThumb", { bg = sel })
  end
end

local function fix_theme_highlights(data)
  if not data then return end

  local bg = data.background
  local bgAccent = data.backgroundAccent
  local hl = data.highlighted
  local ov1 = data.overlay1
  local ov2 = data.overlay2
  local surf2 = data.surface2
  local borderIna = data.borderInactive
  local borderFoc = data.borderFocused

  local fg = data.text
  local st0 = data.subtext0
  local st1 = data.subtext1
  local red = data.red
  local grn = data.green
  local ylw = data.yellow
  local blu = data.blue
  local mve = data.mauve
  local cyn = data.cyan
  local mag = data.magenta
  local mar = data.maroon
  local pch = data.peach
  local sky = data.sky
  local sap = data.sapphire
  local pk = data.pink
  local lvn = data.lavender
  local rsw = data.rosewater
  local flm = data.flamingo

  if not fg or not bg then return end

  vim.api.nvim_set_hl(0, "Normal", { fg = fg, bg = bg })
  vim.api.nvim_set_hl(0, "NormalFloat", { fg = fg, bg = bg })
  if hl then
    vim.api.nvim_set_hl(0, "CursorLine", { bg = hl })
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = fg, bg = hl })
    vim.api.nvim_set_hl(0, "Visual", { bg = hl })
    vim.api.nvim_set_hl(0, "VisualNOS", { bg = hl })
  end
  if st0 then vim.api.nvim_set_hl(0, "LineNr", { fg = st0 }) end

  if ov1 then vim.api.nvim_set_hl(0, "Search", { fg = fg, bg = ov1 }) end
  if ov1 then vim.api.nvim_set_hl(0, "MatchParen", { bg = ov1, bold = true }) end
  if surf2 then
    vim.api.nvim_set_hl(0, "IncSearch", { fg = fg, bg = surf2 })
    vim.api.nvim_set_hl(0, "CurSearch", { fg = fg, bg = surf2 })
  end

  if ov2 then
    if grn then vim.api.nvim_set_hl(0, "DiffAdd", { fg = grn, bg = ov2 }) end
    if red then vim.api.nvim_set_hl(0, "DiffDelete", { fg = red, bg = ov2 }) end
    if ylw then vim.api.nvim_set_hl(0, "DiffChange", { fg = ylw, bg = ov2 }) end
  end
  if hl then vim.api.nvim_set_hl(0, "DiffText", { fg = fg, bg = hl }) end

  if bgAccent then
    vim.api.nvim_set_hl(0, "StatusLine", { fg = fg, bg = bgAccent })
    vim.api.nvim_set_hl(0, "WinBar", { fg = fg, bg = bgAccent })
  end
  if ov2 then
    vim.api.nvim_set_hl(0, "StatusLineNC", { fg = st0 or fg, bg = ov2 })
    vim.api.nvim_set_hl(0, "TabLine", { fg = st0 or fg, bg = ov2 })
    vim.api.nvim_set_hl(0, "TabLineFill", { bg = ov2 })
    vim.api.nvim_set_hl(0, "WinBarNC", { fg = st0 or fg, bg = ov2 })
  end
  vim.api.nvim_set_hl(0, "TabLineSel", { fg = fg, bg = bg })

  if borderFoc then vim.api.nvim_set_hl(0, "FloatBorder", { fg = borderFoc }) end
  vim.api.nvim_set_hl(0, "FloatTitle", { fg = fg })

  if red then
    vim.api.nvim_set_hl(0, "DiagnosticError", { fg = red })
    vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = red })
    vim.api.nvim_set_hl(0, "DiagnosticFloatingError", { fg = red })
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { sp = red, undercurl = true })
  end
  if ylw then
    vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = ylw })
    vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = ylw })
    vim.api.nvim_set_hl(0, "DiagnosticFloatingWarn", { fg = ylw })
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { sp = ylw, undercurl = true })
  end
  if blu then
    vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = blu })
    vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = blu })
    vim.api.nvim_set_hl(0, "DiagnosticFloatingInfo", { fg = blu })
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { sp = blu, undercurl = true })
  end
  if st0 then
    vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = st0 })
    vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = st0 })
    vim.api.nvim_set_hl(0, "DiagnosticFloatingHint", { fg = st0 })
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { sp = st0, undercurl = true })
  end

  if red then vim.api.nvim_set_hl(0, "SpellBad", { sp = red, undercurl = true }) end
  if ylw then vim.api.nvim_set_hl(0, "SpellCap", { sp = ylw, undercurl = true }) end
  if blu then vim.api.nvim_set_hl(0, "SpellLocal", { sp = blu, undercurl = true }) end
  if mve then vim.api.nvim_set_hl(0, "SpellRare", { sp = mve, undercurl = true }) end

  vim.api.nvim_set_hl(0, "SignColumn", { bg = bg })
  if st0 then vim.api.nvim_set_hl(0, "NonText", { fg = st0 }) end
  if borderIna then vim.api.nvim_set_hl(0, "Whitespace", { fg = borderIna }) end
  if st0 then
    vim.api.nvim_set_hl(0, "Folded", { fg = st0 })
    vim.api.nvim_set_hl(0, "FoldColumn", { fg = st0 })
    vim.api.nvim_set_hl(0, "Conceal", { fg = st0 })
  end

  vim.api.nvim_set_hl(0, "TelescopeNormal", { fg = fg, bg = bg })
  if borderFoc then vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = borderFoc, bg = bg }) end
  if bgAccent then
    vim.api.nvim_set_hl(0, "TelescopePromptNormal", { fg = fg, bg = bgAccent })
    vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = borderFoc or fg, bg = bgAccent })
  end
  if st0 then
    vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { fg = st0 })
    vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { fg = st0 })
  end
  vim.api.nvim_set_hl(0, "TelescopePromptTitle", { fg = fg })
  if hl then vim.api.nvim_set_hl(0, "TelescopeSelection", { bg = hl }) end
  if ylw then vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = ylw, bold = true }) end
  vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = fg, bold = true })

  if ov2 then
    vim.api.nvim_set_hl(0, "BufferLineBackground", { fg = st0 or fg, bg = ov2 })
    vim.api.nvim_set_hl(0, "BufferLineBufferVisible", { fg = st0 or fg, bg = ov2 })
    vim.api.nvim_set_hl(0, "BufferLineTab", { fg = st0 or fg, bg = ov2 })
    vim.api.nvim_set_hl(0, "BufferLineFill", { bg = ov2 })
  end
  vim.api.nvim_set_hl(0, "BufferLineSelected", { fg = fg, bg = bg })
  vim.api.nvim_set_hl(0, "BufferLineTabSelected", { fg = fg, bg = bg })
  if borderFoc then vim.api.nvim_set_hl(0, "BufferLineIndicatorSelected", { fg = borderFoc, bg = bg }) end

  vim.api.nvim_set_hl(0, "NvimTreeNormal", { fg = fg, bg = bg })
  vim.api.nvim_set_hl(0, "NvimTreeRootFolder", { fg = fg, bold = true })
  if ylw then vim.api.nvim_set_hl(0, "NvimTreeGitDirty", { fg = ylw }) end
  if grn then vim.api.nvim_set_hl(0, "NvimTreeGitNew", { fg = grn }) end
  if red then vim.api.nvim_set_hl(0, "NvimTreeGitDeleted", { fg = red }) end
  vim.api.nvim_set_hl(0, "NvimTreeOpenedFile", { fg = fg, bold = true })
  if blu then vim.api.nvim_set_hl(0, "NvimTreeFolderName", { fg = blu }) end
  if st0 then vim.api.nvim_set_hl(0, "NvimTreeEmptyFolderName", { fg = st0 }) end
  if borderIna then vim.api.nvim_set_hl(0, "NvimTreeIndentMarker", { fg = borderIna }) end
  if cyn then vim.api.nvim_set_hl(0, "NvimTreeSymlink", { fg = cyn }) end
  if mve then vim.api.nvim_set_hl(0, "NvimTreeImageFile", { fg = mve }) end
  if grn then vim.api.nvim_set_hl(0, "NvimTreeExecFile", { fg = grn }) end
  if ylw then vim.api.nvim_set_hl(0, "NvimTreeSpecialFile", { fg = ylw }) end
  if hl then vim.api.nvim_set_hl(0, "NvimTreeCursorLine", { bg = hl }) end

  vim.api.nvim_set_hl(0, "WhichKey", { fg = fg, bold = true })
  if blu then vim.api.nvim_set_hl(0, "WhichKeyGroup", { fg = blu }) end
  if st0 then vim.api.nvim_set_hl(0, "WhichKeyDesc", { fg = st0 }) end
  if borderIna then vim.api.nvim_set_hl(0, "WhichKeySeparator", { fg = borderIna }) end
  vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = bg })
  if borderFoc then vim.api.nvim_set_hl(0, "WhichKeyBorder", { fg = borderFoc }) end

  if grn then
    vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = grn })
    vim.api.nvim_set_hl(0, "GitSignsAddLn", { fg = grn })
    vim.api.nvim_set_hl(0, "GitSignsAddNr", { fg = grn })
  end
  if ylw then
    vim.api.nvim_set_hl(0, "GitSignsChange", { fg = ylw })
    vim.api.nvim_set_hl(0, "GitSignsChangeLn", { fg = ylw })
    vim.api.nvim_set_hl(0, "GitSignsChangeNr", { fg = ylw })
  end
  if red then
    vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = red })
    vim.api.nvim_set_hl(0, "GitSignsDeleteLn", { fg = red })
    vim.api.nvim_set_hl(0, "GitSignsDeleteNr", { fg = red })
  end

  if borderIna then vim.api.nvim_set_hl(0, "IblIndent", { fg = borderIna }) end
  if borderFoc then vim.api.nvim_set_hl(0, "IblScope", { fg = borderFoc }) end
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
      lualine = true,
      gitsigns = true,
      nvimtree = true,
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
    local ok_theme, lualine_theme = pcall(require, "catppuccin.groups.integrations.lualine")
    lualine.setup { options = { theme = ok_theme and lualine_theme or 'auto' } }
  end

  fix_cmp_highlights(data)
  fix_theme_highlights(data)
  vim.cmd("redraw!")
end

local theme_data = read_headspace_colors()
apply_theme(theme_data)

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

fix_cmp_highlights(theme_data)
fix_theme_highlights(theme_data)

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
local colors_base = os.getenv("XDG_RUNTIME_DIR") or "/run/user/1000"
local watch_path = colors_base .. "/headspace-colors.json"
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
