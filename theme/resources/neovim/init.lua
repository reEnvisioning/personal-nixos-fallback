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

local _hostname = "reEnvisioning"

local function colors_path()
  return (os.getenv("XDG_RUNTIME_DIR") or "/run/user/1000") .. "/" .. _hostname .. "-theme.json"
end

local function read_colors()
  local f = io.open(colors_path(), "r")
  if not f then return nil end
  local content = f:read("*a")
  f:close()
  local ok, data = pcall(vim.json.decode, content)
  if not ok or type(data) ~= "table" then return nil end
  return data
end

--- Build a flat color table from theme data
local function extract_colors(data)
  return {
    bg         = data.background,
    bgAccent   = data.backgroundAccent,
    hl         = data.highlighted,
    ov1        = data.overlay1,
    ov2        = data.overlay2,
    surf2      = data.surface2,
    borderIna  = data.borderInactive,
    borderFoc  = data.borderFocused,
    accent     = data.accent,
    accentL    = data.accent_light,
    accentD    = data.accent_dark,
    crust      = data.crust,
    fg         = data.text,
    st0        = data.subtext0,
    st1        = data.subtext1,
    red        = data.red,
    green      = data.green,
    yellow     = data.yellow,
    blue       = data.blue,
    magenta    = data.magenta,
    cyan       = data.cyan,
    mauve      = data.mauve,
    lavender   = data.lavender,
    pink       = data.pink,
    rosewater  = data.rosewater,
    flamingo   = data.flamingo,
    maroon     = data.maroon,
    peach      = data.peach,
    sky        = data.sky,
    sapphire   = data.sapphire,
    uiErr      = data.ui_error,
    uiWarn     = data.ui_warning,
    uiSucc     = data.ui_success,
    uiInfo     = data.ui_info,
    uiHint     = data.ui_hint,
    uiMatch    = data.ui_match,
  }
end

--- Define all highlight groups from theme colors.
--- Inspired by https://github.com/yorickpeterse/nvim-grey/
local function define_highlights(c)
  if not c or not c.fg or not c.bg then return end

  local hl = {}

  -- Editor chrome
  hl.Normal          = { fg = c.fg, bg = c.bg }
  hl.NormalFloat     = { fg = c.fg, bg = c.bg }
  hl.ColorColumn     = { bg = c.hl }
  hl.Conceal         = { fg = c.st0 }
  hl.Cursor          = { bg = c.fg }
  hl.CursorLine      = { bg = c.hl }
  hl.CursorLineNr    = { fg = c.fg, bg = c.hl }
  hl.Directory       = { fg = c.blue }
  hl.EndOfBuffer     = { fg = c.bg, bg = c.bg }
  hl.ErrorMsg        = { fg = c.uiErr, bold = true }
  hl.FloatBorder     = { fg = c.borderFoc }
  hl.FloatTitle      = { fg = c.fg, bold = true }
  hl.FoldColumn      = { fg = c.st0 }
  hl.Folded          = { fg = c.st0 }
  hl.IncSearch       = { fg = c.fg, bg = c.surf2 }
  hl.CurSearch       = { fg = c.fg, bg = c.surf2 }
  hl.LineNr          = { fg = c.st0 }
  hl.MatchParen      = { bg = c.ov1, bold = true }
  hl.ModeMsg         = { fg = c.fg, bold = true }
  hl.MoreMsg         = { fg = c.fg }
  hl.MsgSeparator    = { fg = c.ov1 }
  hl.NonText         = { fg = c.st0 }
  hl.Pmenu           = { bg = c.hl, fg = c.fg }
  hl.PmenuMatch      = { fg = c.uiMatch, bold = true }
  hl.PmenuSbar       = { bg = c.hl }
  hl.PmenuSel        = { bg = c.surf2, fg = c.fg }
  hl.PmenuThumb      = { bg = c.surf2 }
  hl.Question        = { fg = c.fg }
  hl.QuickFixLine    = { bg = c.hl, bold = true }
  hl.Search          = { fg = c.fg, bg = c.ov1 }
  hl.SignColumn      = { bg = c.bg }
  hl.StatusLine      = { fg = c.fg, bg = c.bgAccent }
  hl.StatusLineNC    = { fg = c.st0, bg = c.ov2 }
  hl.TabLine         = { fg = c.st0, bg = c.ov2 }
  hl.TabLineFill     = { bg = c.ov2 }
  hl.TabLineSel      = { fg = c.fg, bg = c.bg }
  hl.Title           = { fg = c.fg, bold = true }
  hl.Todo            = { fg = c.yellow, bold = true }
  hl.Underlined      = { underline = true }
  hl.VertSplit       = { fg = c.ov1 }
  hl.Visual          = { bg = c.hl }
  hl.VisualNOS       = { bg = c.hl }
  hl.WarningMsg      = { fg = c.uiWarn, bold = true }
  hl.Whitespace      = { fg = c.ov1 }
  hl.WildMenu        = { bg = c.surf2, fg = c.fg }
  hl.WinBar          = { fg = c.fg, bg = c.bgAccent }
  hl.WinBarNC        = { fg = c.st0, bg = c.ov2 }
  hl.WinSeparator    = { fg = c.ov1 }

  -- Diagnostics
  hl.DiagnosticError          = { fg = c.uiErr }
  hl.DiagnosticSignError      = { fg = c.uiErr }
  hl.DiagnosticFloatingError  = { fg = c.uiErr }
  hl.DiagnosticUnderlineError = { sp = c.uiErr, undercurl = true }
  hl.DiagnosticWarn           = { fg = c.uiWarn }
  hl.DiagnosticSignWarn       = { fg = c.uiWarn }
  hl.DiagnosticFloatingWarn   = { fg = c.uiWarn }
  hl.DiagnosticUnderlineWarn  = { sp = c.uiWarn, undercurl = true }
  hl.DiagnosticInfo           = { fg = c.uiInfo }
  hl.DiagnosticSignInfo       = { fg = c.uiInfo }
  hl.DiagnosticFloatingInfo   = { fg = c.uiInfo }
  hl.DiagnosticUnderlineInfo  = { sp = c.uiInfo, undercurl = true }
  hl.DiagnosticHint           = { fg = c.uiHint }
  hl.DiagnosticSignHint       = { fg = c.uiHint }
  hl.DiagnosticFloatingHint   = { fg = c.uiHint }
  hl.DiagnosticUnderlineHint  = { sp = c.uiHint, undercurl = true }
  hl.DiagnosticDeprecated     = { strikethrough = true }
  hl.DiagnosticUnnecessary    = { fg = c.st0 }
  hl.LspInlayHint             = { fg = c.st0, bg = c.hl }
  hl.LspReferenceText         = { bg = c.hl }
  hl.LspReferenceRead         = { bg = c.hl }
  hl.LspReferenceWrite        = { bg = c.hl }

  -- Diffs
  hl.DiffAdd    = { fg = c.uiSucc, bg = c.ov2 }
  hl.DiffChange = { fg = c.uiWarn, bg = c.ov2 }
  hl.DiffDelete = { fg = c.uiErr, bg = c.ov2 }
  hl.DiffText   = { fg = c.fg, bg = c.hl }

  -- Spell
  hl.SpellBad   = { sp = c.uiErr, undercurl = true }
  hl.SpellCap   = { sp = c.uiWarn, undercurl = true }
  hl.SpellLocal = { sp = c.uiInfo, undercurl = true }
  hl.SpellRare  = { sp = c.uiInfo, undercurl = true }

  -- Legacy syntax groups
  hl.Comment      = { fg = c.green }
  hl.Constant     = { fg = c.cyan }
  hl.String       = { fg = c.red }
  hl.Character    = { link = "String" }
  hl.Number       = { fg = c.cyan }
  hl.Boolean      = { link = "Number" }
  hl.Float        = { link = "Number" }
  hl.Identifier   = { fg = c.fg }
  hl.Function     = { fg = c.blue }
  hl.Statement    = { fg = c.blue, bold = true }
  hl.Conditional  = { link = "Statement" }
  hl.Repeat       = { link = "Statement" }
  hl.Label        = { fg = c.magenta }
  hl.Operator     = { fg = c.peach }
  hl.Keyword      = { fg = c.blue, bold = true }
  hl.Exception    = { link = "Keyword" }
  hl.Include      = { fg = c.magenta }
  hl.Define       = { link = "PreProc" }
  hl.Macro        = { fg = c.magenta }
  hl.PreCondit    = { link = "PreProc" }
  hl.PreProc      = { fg = c.magenta }
  hl.StorageClass = { fg = c.mauve }
  hl.Structure    = { fg = c.mauve }
  hl.Typedef      = { link = "Type" }
  hl.Type         = { fg = c.mauve }
  hl.Special      = { fg = c.peach }
  hl.SpecialChar  = { link = "Special" }
  hl.Tag          = { fg = c.blue }
  hl.Delimiter    = { fg = c.peach }
  hl.SpecialComment = { fg = c.green }
  hl.Debug        = { fg = c.yellow }
  hl.Error        = { link = "DiagnosticError" }
  hl.Ignore       = {}

  -- Tree-sitter captures
  hl["@comment"]             = { fg = c.green }
  hl["@error"]               = { fg = c.uiErr }
  hl["@warning"]             = { fg = c.uiWarn }
  hl["@note"]                = { fg = c.uiInfo }
  hl["@todo"]                = { fg = c.yellow, bold = true }
  hl["@string"]              = { fg = c.red }
  hl["@string.regexp"]       = { fg = c.peach }
  hl["@string.escape"]       = { fg = c.red }
  hl["@character"]           = { fg = c.red }
  hl["@character.special"]   = { link = "@string.escape" }
  hl["@number"]              = { fg = c.cyan }
  hl["@boolean"]             = { fg = c.cyan }
  hl["@float"]               = { fg = c.cyan }
  hl["@function"]            = { fg = c.blue }
  hl["@function.builtin"]    = { fg = c.blue, bold = true }
  hl["@function.macro"]      = { fg = c.magenta }
  hl["@method"]              = { fg = c.blue }
  hl["@constructor"]         = { fg = c.pink }
  hl["@keyword"]             = { fg = c.blue, bold = true }
  hl["@keyword.function"]    = { fg = c.blue, bold = true }
  hl["@keyword.return"]      = { fg = c.blue, bold = true }
  hl["@keyword.operator"]    = { fg = c.peach }
  hl["@include"]             = { fg = c.magenta }
  hl["@label"]               = { fg = c.magenta }
  hl["@operator"]            = { fg = c.peach }
  hl["@type"]                = { fg = c.mauve }
  hl["@type.builtin"]        = { fg = c.maroon }
  hl["@type.qualifier"]      = { fg = c.mauve }
  hl["@attribute"]           = { fg = c.yellow }
  hl["@property"]            = { fg = c.sky }
  hl["@field"]               = { fg = c.sky }
  hl["@parameter"]           = { fg = c.lavender }
  hl["@variable"]            = { fg = c.fg }
  hl["@variable.builtin"]    = { fg = c.maroon }
  hl["@constant"]            = { fg = c.cyan }
  hl["@constant.builtin"]    = { fg = c.maroon }
  hl["@namespace"]           = { fg = c.sapphire }
  hl["@symbol"]              = { fg = c.peach }
  hl["@text"]                = { fg = c.fg }
  hl["@text.strong"]         = { fg = c.fg, bold = true }
  hl["@text.emphasis"]       = { fg = c.fg, italic = true }
  hl["@text.underline"]      = { fg = c.fg, underline = true }
  hl["@text.title"]          = { fg = c.fg, bold = true }
  hl["@text.literal"]        = { fg = c.green }
  hl["@text.uri"]            = { fg = c.blue, underline = true }
  hl["@text.reference"]      = { fg = c.mauve }
  hl["@text.todo"]           = { fg = c.yellow, bold = true }
  hl["@text.note"]           = { fg = c.blue, bold = true }
  hl["@text.warning"]        = { fg = c.yellow, bold = true }
  hl["@text.danger"]         = { fg = c.red, bold = true }
  hl["@tag"]                 = { fg = c.blue }
  hl["@tag.attribute"]       = { fg = c.yellow }
  hl["@tag.delimiter"]       = { fg = c.st0 }
  hl["@punctuation.delimiter"] = { fg = c.peach }
  hl["@punctuation.bracket"]   = { fg = c.peach }
  hl["@punctuation.special"]   = { fg = c.peach }

  -- LSP semantic token links
  hl["@lsp.type.comment"]      = { link = "@comment" }
  hl["@lsp.type.enum"]         = { link = "@type" }
  hl["@lsp.type.enumMember"]   = { link = "@constant" }
  hl["@lsp.type.function"]     = { link = "@function" }
  hl["@lsp.type.interface"]    = { link = "@type" }
  hl["@lsp.type.keyword"]      = { link = "@keyword" }
  hl["@lsp.type.macro"]        = { link = "@function.macro" }
  hl["@lsp.type.method"]       = { link = "@method" }
  hl["@lsp.type.namespace"]    = { link = "@namespace" }
  hl["@lsp.type.parameter"]    = { link = "@parameter" }
  hl["@lsp.type.property"]     = { link = "@property" }
  hl["@lsp.type.struct"]       = { link = "@type" }
  hl["@lsp.type.type"]         = { link = "@type" }
  hl["@lsp.type.typeParameter"] = { link = "@type" }
  hl["@lsp.type.variable"]     = { link = "@variable" }

  -- Telescope
  hl.TelescopeNormal        = { fg = c.fg, bg = c.bg }
  hl.TelescopeBorder        = { fg = c.borderFoc, bg = c.bg }
  hl.TelescopePromptNormal  = { fg = c.fg, bg = c.bgAccent }
  hl.TelescopePromptBorder  = { fg = c.borderFoc, bg = c.bgAccent }
  hl.TelescopeResultsTitle  = { fg = c.st0 }
  hl.TelescopePreviewTitle  = { fg = c.st0 }
  hl.TelescopePromptTitle   = { fg = c.fg }
  hl.TelescopeSelection     = { bg = c.hl }
  hl.TelescopeMatching      = { fg = c.uiMatch, bold = true }
  hl.TelescopePromptPrefix  = { fg = c.fg, bold = true }

  -- NvimTree
  hl.NvimTreeNormal          = { fg = c.fg, bg = c.bg }
  hl.NvimTreeRootFolder      = { fg = c.fg, bold = true }
  hl.NvimTreeGitDirty        = { fg = c.uiWarn }
  hl.NvimTreeGitNew          = { fg = c.uiSucc }
  hl.NvimTreeGitDeleted      = { fg = c.uiErr }
  hl.NvimTreeOpenedFile      = { fg = c.fg, bold = true }
  hl.NvimTreeFolderName      = { fg = c.uiInfo }
  hl.NvimTreeEmptyFolderName = { fg = c.st0 }
  hl.NvimTreeIndentMarker    = { fg = c.borderIna }
  hl.NvimTreeSymlink         = { fg = c.cyan }
  hl.NvimTreeImageFile       = { fg = c.mauve }
  hl.NvimTreeExecFile        = { fg = c.green }
  hl.NvimTreeSpecialFile     = { fg = c.yellow }
  hl.NvimTreeCursorLine      = { bg = c.hl }

  -- GitSigns
  hl.GitSignsAdd       = { fg = c.uiSucc }
  hl.GitSignsAddLn     = { fg = c.uiSucc }
  hl.GitSignsAddNr     = { fg = c.uiSucc }
  hl.GitSignsChange    = { fg = c.uiWarn }
  hl.GitSignsChangeLn  = { fg = c.uiWarn }
  hl.GitSignsChangeNr  = { fg = c.uiWarn }
  hl.GitSignsDelete    = { fg = c.uiErr }
  hl.GitSignsDeleteLn  = { fg = c.uiErr }
  hl.GitSignsDeleteNr  = { fg = c.uiErr }

  -- Indent Blankline
  hl.IblIndent = { fg = c.borderIna }
  hl.IblScope  = { fg = c.borderFoc }

  -- Apply all highlights
  for group, opts in pairs(hl) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

--- Apply the theme
local function apply_theme(data)
  if not data then return end

  vim.o.background = data.mode == "light" and "light" or "dark"

  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  vim.g.colors_name = _hostname .. "-theme"

  local c = extract_colors(data)
  define_highlights(c)

  local ok_lualine, lualine = pcall(require, "lualine")
  if ok_lualine then
    lualine.setup {
      options = {
        theme = {
          normal = {
            a = { fg = c.fg, bg = c.bgAccent, gui = "bold" },
            b = { fg = c.fg, bg = c.ov2 },
            c = { fg = c.fg, bg = c.bg },
          },
          insert = { a = { fg = c.bg, bg = c.uiInfo, gui = "bold" } },
          visual = { a = { fg = c.bg, bg = c.uiSucc, gui = "bold" } },
          replace = { a = { fg = c.bg, bg = c.uiErr, gui = "bold" } },
          command = { a = { fg = c.bg, bg = c.uiWarn, gui = "bold" } },
          inactive = {
            a = { fg = c.st0, bg = c.ov2 },
            b = { fg = c.st0, bg = c.ov2 },
            c = { fg = c.st0, bg = c.bg },
          },
        },
      },
    }
  end

  vim.cmd("redraw!")
end

-- Apply theme on startup
local theme_data = read_colors()
apply_theme(theme_data)

-- Plugin setups
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

-- Live-switching: watch colors.json for changes
local uv = vim.uv or vim.loop
local watch_path = colors_path()
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
        local data = read_colors()
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
