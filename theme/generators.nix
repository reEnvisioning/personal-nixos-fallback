let
  hexChars = "0123456789abcdef";

  toHexPair = v:
    let
      hi = v / 16;
      lo = v - hi * 16;
    in "${builtins.substring hi 1 hexChars}${builtins.substring lo 1 hexChars}";

  # Color mapping from theme.json to radiance.toml roles
  colorMap = c: {
    bg = c.background;
    "bg-2" = c.surface2;
    ui = c.overlay1;
    "ui-3" = c.overlay2;
    tx = c.text;
    "tx-2" = c.subtext0;
    "tx-3" = c.subtext1;
    cy = c.cyan;
    "cy-300" = c.mauve;
    "cy-100" = c.flamingo;
    gr = c.green;
    ye = c.yellow;
    re = c.red;
    or = c.peach;
    bl = c.blue;
    ma = c.magenta;
  };

  lightenHex = hex: pct:
    let
      r = builtins.fromJSON (builtins.substring 1 2 hex);
      g = builtins.fromJSON (builtins.substring 3 2 hex);
      b = builtins.fromJSON (builtins.substring 5 2 hex);
      r' = r + (255 - r) * pct / 100;
      g' = g + (255 - g) * pct / 100;
      b' = b + (255 - b) * pct / 100;
    in "#${toHexPair r'}${toHexPair g'}${toHexPair b'}";

  darkenHex = hex: pct:
    let
      r = builtins.fromJSON (builtins.substring 1 2 hex);
      g = builtins.fromJSON (builtins.substring 3 2 hex);
      b = builtins.fromJSON (builtins.substring 5 2 hex);
      r' = r * (100 - pct) / 100;
      g' = g * (100 - pct) / 100;
      b' = b * (100 - pct) / 100;
    in "#${toHexPair r'}${toHexPair g'}${toHexPair b'}";

in {
  # Generate kitty.conf from theme colors
  mkKittyConf = t: ''
    background ${t.colors.background}
    foreground ${t.colors.text}
    cursor ${t.colors.text}
    selection_background ${t.colors.highlighted}
    selection_foreground ${t.colors.background}
    color0 ${t.colors.background}
    color1 ${t.colors.red}
    color2 ${t.colors.green}
    color3 ${t.colors.yellow}
    color4 ${t.colors.blue}
    color5 ${t.colors.magenta}
    color6 ${t.colors.cyan}
    color7 ${t.colors.text}
    color8 ${t.colors.backgroundAccent}
    color9 ${t.colors.red}
    color10 ${t.colors.green}
    color11 ${t.colors.yellow}
    color12 ${t.colors.blue}
    color13 ${t.colors.magenta}
    color14 ${t.colors.cyan}
    color15 ${t.colors.background}
    font_family Monospace
    font_size 10
    confirm_os_window_close 0
  '';

  # Generate btop theme from theme colors
  mkBtopTheme = t: let
    c = t.colors;
    processStart = lightenHex c.overlay2 20;
    processMid = c.overlay2;
    processEnd = darkenHex c.overlay2 30;
  in ''
    theme[main_bg]=${c.background}
    theme[main_fg]=${c.text}
    theme[title]=${c.text}
    theme[hi_fg]=${c.mauve}
    theme[selected_bg]=${c.highlighted}
    theme[selected_fg]=${c.text}
    theme[inactive_fg]=${c.subtext0}
    theme[graph_text]=${c.mauve}
    theme[meter_bg]=${c.overlay2}
    theme[proc_misc]=${c.mauve}
    theme[cpu_box]=${c.mauve}
    theme[mem_box]=${c.green}
    theme[net_box]=${c.maroon}
    theme[proc_box]=${c.blue}
    theme[div_line]=${c.overlay1}
    theme[temp_start]=${c.green}
    theme[temp_mid]=${c.yellow}
    theme[temp_end]=${c.red}
    theme[cpu_start]=${c.cyan}
    theme[cpu_mid]=${c.sapphire}
    theme[cpu_end]=${c.lavender}
    theme[free_start]=${c.mauve}
    theme[free_mid]=${c.lavender}
    theme[free_end]=${c.blue}
    theme[cached_start]=${c.sapphire}
    theme[cached_mid]=${c.blue}
    theme[cached_end]=${c.lavender}
    theme[available_start]=${c.peach}
    theme[available_mid]=${c.maroon}
    theme[available_end]=${c.red}
    theme[used_start]=${c.green}
    theme[used_mid]=${c.cyan}
    theme[used_end]=${c.sky}
    theme[download_start]=${c.peach}
    theme[download_mid]=${c.maroon}
    theme[download_end]=${c.red}
    theme[upload_start]=${c.green}
    theme[upload_mid]=${c.cyan}
    theme[upload_end]=${c.sky}
    theme[process_start]=${processStart}
    theme[process_mid]=${processMid}
    theme[process_end]=${processEnd}
  '';

  # Generate yazi theme from theme colors (radiance.toml structure)
  mkYaziTheme = t: let
    m = colorMap t.colors;
  in ''
    [app]
    overall = { bg = "${m.bg}" }

    [mgr]
    cwd = { fg = "${m.tx}", bold = true }
    find_keyword = { fg = "${m.cy}", reversed = true }
    find_position = { fg = "${m.cy}", bold = true, italic = true }
    marker_copied = { fg = "${m.gr}", bg = "${m.gr}" }
    marker_cut = { fg = "${m.re}", bg = "${m.re}" }
    marker_marked = { fg = "${m.cy-300}", bg = "${m.cy-300}" }
    marker_selected = { fg = "${m.cy}", bg = "${m.cy}" }
    count_copied = { fg = "${m.gr}", bold = true, reversed = true }
    count_cut = { fg = "${m.re}", bold = true, reversed = true }
    count_selected = { fg = "${m.cy}", bold = true, reversed = true }
    border_symbol = "│"
    border_style = { fg = "${m.ui}" }

    [indicator]
    parent = { underline = true }
    current = { fg = "${m.tx}", bg = "${m.ui}" }
    preview = { underline = true }
    padding = { open = "█", close = "█" }

    [tabs]
    active = { fg = "${m.tx}", bg = "${m.ui-3}", bold = true }
    inactive = { fg = "${m.tx-2}", bg = "${m.ui}" }
    sep_inner = { open = "", close = "" }
    sep_outer = { open = "", close = "" }

    [mode]
    normal_main = { fg = "${m.tx}", bg = "${m.ui-3}", bold = true }
    normal_alt = { fg = "${m.tx-2}", bg = "${m.ui}" }
    select_main = { fg = "${m.bg}", bg = "${m.cy}", bold = true }
    select_alt = { fg = "${m.cy}", bg = "${m.cy-100}" }
    unset_main = { fg = "${m.bg}", bg = "${m.cy}", bold = true }
    unset_alt = { fg = "${m.cy}", bg = "${m.cy-100}" }

    [status]
    overall = { fg = "${m.tx}" }
    perm_type = { fg = "${m.bl}" }
    perm_read = { fg = "${m.ye}" }
    perm_write = { fg = "${m.re}" }
    perm_exec = { fg = "${m.gr}" }
    perm_sep = { fg = "${m.tx-2}" }
    progress_label = { fg = "${m.bg}" }
    progress_normal = { fg = "${m.cy}", bg = "${m.cy-300}" }
    progress_error = { bg = "${m.re}" }

    [which]
    cols = 3
    mask = { bg = "${m.bg-2}" }
    cand = { fg = "${m.cy}", bold = true }
    rest = { fg = "${m.cy}", italic = true }
    desc = { fg = "${m.tx-3}" }
    separator = " "
    separator_style = { }

    [confirm]
    border = { fg = "${m.ui-3}" }
    title = { fg = "${m.tx-3}", bold = true }
    body = { fg = "${m.tx}", bold = true }
    list = { fg = "${m.tx}" }
    btn_yes = { fg = "${m.tx}", bg = "${m.ui-3}", bold = true }
    btn_no = { fg = "${m.tx-2}", bg = "${m.ui}" }

    [spot]
    border = { fg = "${m.ui-3}" }
    title = { fg = "${m.tx-3}", bold = true }
    tbl_col = { fg = "${m.tx-2}" }
    tbl_cell = { fg = "${m.tx}", bg = "${m.ui}" }

    [notify]
    title_info = { fg = "${m.bl}" }
    title_warn = { fg = "${m.or}" }
    title_error = { fg = "${m.re}" }

    [pick]
    border = { fg = "${m.ui-3}", bold = true }
    active = { fg = "${m.tx}" }
    inactive = { fg = "${m.tx-2}" }

    [input]
    border = { fg = "${m.ui-3}" }
    title = { fg = "${m.tx-3}", bold = true }
    value = { fg = "${m.tx}" }
    selected = { bg = "${m.bg-2}" }

    [cmp]
    border = { fg = "${m.ui-3}", bold = true }
    active = { fg = "${m.tx}", bg = "${m.ui}" }
    inactive = { fg = "${m.tx-2}" }

    [tasks]
    border = { fg = "${m.ui-3}" }
    title = { fg = "${m.tx-3}", bold = true }
    hovered = { fg = "${m.tx}", bg = "${m.ui}" }

    [help]
    on = { fg = "${m.bl}" }
    run = { fg = "${m.cy}" }
    desc = { fg = "${m.tx-3}", italic = true }
    hovered = { bg = "${m.ui}" }
    footer = { fg = "${m.bg}", bg = "${m.cy}", bold = true }

    [filetype]
    rules = [
      { mime = "inode/empty", fg = "${m.tx-3}" },
      { url = "*", is = "orphan", fg = "${m.tx-3}" },
      { url = "*/", is = "orphan", fg = "${m.tx-3}" },
      { url = "*", is = "link", fg = "${m.cy}" },
      { url = "*/", is = "link", fg = "${m.cy}" },
      { url = "*", is = "block", fg = "${m.tx}" },
      { url = "*", is = "char", fg = "${m.tx}" },
      { url = "*", is = "fifo", fg = "${m.ma}" },
      { url = "*", is = "sock", fg = "${m.ma}" },
      { url = "*", is = "sticky", fg = "${m.tx}" },
      { url = "*", is = "dummy", fg = "${m.tx-3}" },
      { url = "*/", fg = "${m.tx}" },
      { url = "*", is = "exec", fg = "${m.gr}" },
      { url = "*", fg = "${m.tx-2}" }
    ]

    [icon]
    dirs = [
      { name = ".config", text = "", fg = "${m.cy}" },
      { name = ".git", text = "", fg = "${m.cy}" },
      { name = ".github", text = "", fg = "${m.cy}" },
      { name = ".npm", text = "", fg = "${m.cy}" },
      { name = "Desktop", text = "", fg = "${m.cy}" },
      { name = "Development", text = "", fg = "${m.cy}" },
      { name = "Documents", text = "", fg = "${m.cy}" },
      { name = "Downloads", text = "", fg = "${m.cy}" },
      { name = "Library", text = "", fg = "${m.cy}" },
      { name = "Movies", text = "", fg = "${m.cy}" },
      { name = "Music", text = "", fg = "${m.cy}" },
      { name = "Pictures", text = "", fg = "${m.cy}" },
      { name = "Public", text = "", fg = "${m.cy}" },
      { name = "Videos", text = "", fg = "${m.cy}" }
    ]
    conds = [
      { if = "orphan", text = "", fg = "${m.tx-3}" },
      { if = "link", text = "", fg = "${m.cy}" },
      { if = "block", text = "", fg = "${m.tx}" },
      { if = "char", text = "", fg = "${m.tx}" },
      { if = "fifo", text = "", fg = "${m.ma}" },
      { if = "sock", text = "", fg = "${m.ma}" },
      { if = "sticky", text = "", fg = "${m.tx}" },
      { if = "dummy", text = "", fg = "${m.tx-3}" },
      { if = "dir", text = "", fg = "${m.cy}" },
      { if = "exec", text = "", fg = "${m.gr}" },
      { if = "!dir", text = "", fg = "${m.tx-2}" }
    ]
  '';
}
