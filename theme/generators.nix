let
  hexChars = "0123456789abcdef";

  hexDigitToInt = c: {
    "0" = 0; "1" = 1; "2" = 2; "3" = 3; "4" = 4;
    "5" = 5; "6" = 6; "7" = 7; "8" = 8; "9" = 9;
    "a" = 10; "b" = 11; "c" = 12; "d" = 13; "e" = 14; "f" = 15;
    "A" = 10; "B" = 11; "C" = 12; "D" = 13; "E" = 14; "F" = 15;
  }.${c};

  hexByteToInt = s:
    hexDigitToInt (builtins.substring 0 1 s) * 16 +
    hexDigitToInt (builtins.substring 1 1 s);

  toHexPair = v:
    let
      hi = v / 16;
      lo = v - hi * 16;
    in "${builtins.substring hi 1 hexChars}${builtins.substring lo 1 hexChars}";

  lightenHex = hex: pct:
    let
      r = hexByteToInt (builtins.substring 1 2 hex);
      g = hexByteToInt (builtins.substring 3 2 hex);
      b = hexByteToInt (builtins.substring 5 2 hex);
      r' = r + (255 - r) * pct / 100;
      g' = g + (255 - g) * pct / 100;
      b' = b + (255 - b) * pct / 100;
    in "#${toHexPair r'}${toHexPair g'}${toHexPair b'}";

  darkenHex = hex: pct:
    let
      r = hexByteToInt (builtins.substring 1 2 hex);
      g = hexByteToInt (builtins.substring 3 2 hex);
      b = hexByteToInt (builtins.substring 5 2 hex);
      r' = r * (100 - pct) / 100;
      g' = g * (100 - pct) / 100;
      b' = b * (100 - pct) / 100;
    in "#${toHexPair r'}${toHexPair g'}${toHexPair b'}";

in {
  # Generate kitty.conf from theme colors
  mkKittyConf = t: let c = t.colors; in ''
    background ${c.background}
    foreground ${c.text}
    cursor ${c.cursor}
    selection_background ${c.highlighted}
    selection_foreground ${c.background}
    url_color ${c.link}

    # Normal colors
    color0 ${c.background}
    color1 ${c.red}
    color2 ${c.green}
    color3 ${c.yellow}
    color4 ${c.blue}
    color5 ${c.magenta}
    color6 ${c.cyan}
    color7 ${c.text}

    # Bright colors
    color8 ${c.overlay2}
    color9 ${c.maroon}
    color10 ${c.yellow}
    color11 ${c.peach}
    color12 ${c.sky}
    color13 ${c.pink}
    color14 ${c.sapphire}
    color15 ${c.subtext0}

    # Marks
    mark1_foreground ${c.ui_info}
    mark2_foreground ${c.ui_success}
    mark3_foreground ${c.ui_warning}

    # Tabs
    tab_bar_background ${c.backgroundAccent}
    tab_bar_margin_color ${c.background}
    active_tab_background ${c.highlighted}
    active_tab_foreground ${c.text}
    inactive_tab_background ${c.overlay2}
    inactive_tab_foreground ${c.subtext0}

    # Window
    active_border_color ${c.border}
    inactive_border_color ${c.overlay2}

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
    theme[hi_fg]=${c.ui_match}
    theme[selected_bg]=${c.highlighted}
    theme[selected_fg]=${c.text}
    theme[inactive_fg]=${c.subtext0}
    theme[graph_text]=${c.subtext1}
    theme[meter_bg]=${c.overlay2}
    theme[proc_misc]=${c.mauve}
    theme[cpu_box]=${c.cyan}
    theme[mem_box]=${c.green}
    theme[net_box]=${c.sky}
    theme[proc_box]=${c.lavender}
    theme[div_line]=${c.overlay1}

    # Temperature graph
    theme[temp_start]=${c.green}
    theme[temp_mid]=${c.yellow}
    theme[temp_end]=${c.ui_error}

    # CPU graph
    theme[cpu_start]=${c.cyan}
    theme[cpu_mid]=${c.sapphire}
    theme[cpu_end]=${c.lavender}

    # Mem/Disk free meter
    theme[free_start]=${c.chart_1}
    theme[free_mid]=${c.chart_3}
    theme[free_end]=${c.chart_2}

    # Mem/Disk cached meter
    theme[cached_start]=${c.sapphire}
    theme[cached_mid]=${c.blue}
    theme[cached_end]=${c.sky}

    # Mem/Disk available meter
    theme[available_start]=${c.green}
    theme[available_mid]=${c.yellow}
    theme[available_end]=${c.peach}

    # Mem/Disk used meter
    theme[used_start]=${c.chart_2}
    theme[used_mid]=${c.chart_5}
    theme[used_end]=${c.chart_1}

    # Download graph
    theme[download_start]=${c.chart_2}
    theme[download_mid]=${c.chart_6}
    theme[download_end]=${c.chart_4}

    # Upload graph
    theme[upload_start]=${c.chart_1}
    theme[upload_mid]=${c.chart_5}
    theme[upload_end]=${c.chart_3}

    # Process box gradient
    theme[process_start]=${processStart}
    theme[process_mid]=${processMid}
    theme[process_end]=${processEnd}

    # Process list banner
    theme[proc_pause_bg]=${c.status_inactive}
    theme[proc_follow_bg]=${c.status_syncing}
    theme[proc_banner_bg]=${c.status_processing}
    theme[proc_banner_fg]=${c.text}
    theme[followed_bg]=${c.highlighted}
    theme[followed_fg]=${c.ui_info}
  '';

  # Generate yazi theme from theme colors
  mkYaziTheme = t: let
    c = t.colors;
    m = {
      bg = c.background;
      "bg-2" = c.surface;
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
      pk = c.pink;
      la = c.lavender;
      sa = c.sapphire;
      sk = c.sky;
      rw = c.rosewater;
      fl = c.flamingo;
      mr = c.maroon;
      err = c.ui_error;
      warn = c.ui_warning;
      succ = c.ui_success;
      inf = c.ui_info;
      hnt = c.ui_hint;
      mtch = c.ui_match;
      ia = c.interactive;
      "ia-h" = c.interactive_hover;
      "ia-p" = c.interactive_pressed;
      "ia-d" = c.interactive_disabled;
      st_a = c.status_active;
      st_i = c.status_inactive;
      t_snd = c.transfer_send;
      t_rcv = c.transfer_receive;
      t_cpl = c.transfer_complete;
      t_fld = c.transfer_failed;
      brd = c.border;
      dvr = c.divider;
      el1 = c.elevation_1;
      el2 = c.elevation_2;
      el3 = c.elevation_3;
    };
  in ''
    [app]
    overall = { bg = "${m.bg}" }

    [mgr]
    cwd = { fg = "${m.tx}", bold = true }
    find_keyword = { fg = "${m.cy}", reversed = true }
    find_position = { fg = "${m.cy}", bold = true, italic = true }
    symlink_target = { fg = "${m.sk}" }
    marker_copied = { fg = "${m.gr}", bg = "${m.gr}" }
    marker_cut = { fg = "${m.re}", bg = "${m.re}" }
    marker_marked = { fg = "${m.la}", bg = "${m.la}" }
    marker_selected = { fg = "${m.cy}", bg = "${m.cy}" }
    count_copied = { fg = "${m.gr}", bold = true, reversed = true }
    count_cut = { fg = "${m.re}", bold = true, reversed = true }
    count_selected = { fg = "${m.cy}", bold = true, reversed = true }
    border_symbol = "│"
    border_style = { fg = "${m.brd}" }

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
    unset_main = { fg = "${m.bg}", bg = "${m.pk}", bold = true }
    unset_alt = { fg = "${m.pk}", bg = "${m.cy-100}" }

    [status]
    overall = { fg = "${m.tx}" }
    sep_left = { open = "", close = "]" }
    sep_right = { open = "[", close = "" }
    perm_type = { fg = "${m.bl}" }
    perm_read = { fg = "${m.ye}" }
    perm_write = { fg = "${m.re}" }
    perm_exec = { fg = "${m.gr}" }
    perm_sep = { fg = "${m.tx-2}" }
    progress_label = { fg = "${m.bg}" }
    progress_normal = { fg = "${m.bg}", bg = "${m.t_cpl}" }
    progress_error = { bg = "${m.t_fld}" }

    [which]
    cols = 3
    mask = { bg = "${m.bg-2}" }
    cand = { fg = "${m.cy}", bold = true }
    rest = { fg = "${m.cy}", italic = true }
    desc = { fg = "${m.tx-3}" }
    separator = " "
    separator_style = { fg = "${m.tx-3}" }

    [confirm]
    border = { fg = "${m.brd}" }
    title = { fg = "${m.tx-3}", bold = true }
    body = { fg = "${m.tx}", bold = true }
    list = { fg = "${m.tx}" }
    btn_yes = { fg = "${m.tx}", bg = "${m.t_cpl}", bold = true }
    btn_no = { fg = "${m.tx-2}", bg = "${m.ui}" }
    btn_labels = [ "Yes", "No" ]

    [spot]
    border = { fg = "${m.brd}" }
    title = { fg = "${m.tx-3}", bold = true }
    tbl_col = { fg = "${m.tx-2}" }
    tbl_cell = { fg = "${m.tx}", bg = "${m.ui}" }

    [notify]
    title_info = { fg = "${m.inf}" }
    title_warn = { fg = "${m.warn}" }
    title_error = { fg = "${m.err}" }

    [pick]
    border = { fg = "${m.brd}", bold = true }
    active = { fg = "${m.tx}" }
    inactive = { fg = "${m.tx-2}" }

    [input]
    border = { fg = "${m.brd}" }
    title = { fg = "${m.tx-3}", bold = true }
    value = { fg = "${m.tx}" }
    selected = { bg = "${m.bg-2}" }

    [cmp]
    border = { fg = "${m.brd}", bold = true }
    active = { fg = "${m.tx}", bg = "${m.ui}" }
    inactive = { fg = "${m.tx-2}" }
    icon_file = ""
    icon_folder = ""
    icon_command = ""

    [tasks]
    border = { fg = "${m.brd}" }
    title = { fg = "${m.tx-3}", bold = true }
    hovered = { fg = "${m.tx}", bg = "${m.ui}" }

    [help]
    on = { fg = "${m.bl}" }
    run = { fg = "${m.cy}" }
    desc = { fg = "${m.tx-3}", italic = true }
    hovered = { bg = "${m.ui}" }
    footer = { fg = "${m.bg}", bg = "${m.cy}", bold = true }
    icon_info = "ℹ"
    icon_warn = "⚠"
    icon_error = "✖"

    [filetype]
    rules = [
      { mime = "inode/empty", fg = "${m.hnt}" },
      { url = "*", is = "orphan", fg = "${m.hnt}" },
      { url = "*/", is = "orphan", fg = "${m.hnt}" },
      { url = "*", is = "link", fg = "${m.sk}" },
      { url = "*/", is = "link", fg = "${m.sk}" },
      { url = "*", is = "block", fg = "${m.mr}" },
      { url = "*", is = "char", fg = "${m.mr}" },
      { url = "*", is = "fifo", fg = "${m.ma}" },
      { url = "*", is = "sock", fg = "${m.ma}" },
      { url = "*", is = "sticky", fg = "${m.mtch}" },
      { url = "*", is = "dummy", fg = "${m.hnt}" },
      { url = "*/", fg = "${m.bl}" },
      { url = "*", is = "exec", fg = "${m.gr}" },
      { mime = "image/*", fg = "${m.pk}" },
      { mime = "video/*", fg = "${m.ma}" },
      { mime = "audio/*", fg = "${m.la}" },
      { mime = "text/*", fg = "${m.tx}" },
      { mime = "application/json", fg = "${m.ye}" },
      { mime = "application/zip", fg = "${m.mr}" },
      { mime = "application/pdf", fg = "${m.re}" },
      { url = "*", fg = "${m.tx-2}" }
    ]

    [icon]
    dirs = [
      { name = ".config", text = "", fg = "${m.cy}" },
      { name = ".git", text = "", fg = "${m.or}" },
      { name = ".github", text = "", fg = "${m.tx-2}" },
      { name = ".npm", text = "", fg = "${m.re}" },
      { name = "Desktop", text = "", fg = "${m.bl}" },
      { name = "Development", text = "", fg = "${m.gr}" },
      { name = "Documents", text = "", fg = "${m.ye}" },
      { name = "Downloads", text = "", fg = "${m.sk}" },
      { name = "Library", text = "", fg = "${m.la}" },
      { name = "Movies", text = "", fg = "${m.ma}" },
      { name = "Music", text = "", fg = "${m.pk}" },
      { name = "Pictures", text = "", fg = "${m.cy}" },
      { name = "Public", text = "", fg = "${m.tx-2}" },
      { name = "Videos", text = "", fg = "${m.mr}" }
    ]
    conds = [
      { if = "orphan", text = "", fg = "${m.hnt}" },
      { if = "link", text = "", fg = "${m.sk}" },
      { if = "block", text = "", fg = "${m.mr}" },
      { if = "char", text = "", fg = "${m.mr}" },
      { if = "fifo", text = "", fg = "${m.ma}" },
      { if = "sock", text = "", fg = "${m.ma}" },
      { if = "sticky", text = "", fg = "${m.mtch}" },
      { if = "dummy", text = "", fg = "${m.hnt}" },
      { if = "dir", text = "", fg = "${m.cy}" },
      { if = "exec", text = "", fg = "${m.gr}" },
      { if = "!dir", text = "", fg = "${m.tx-2}" }
    ]
  '';
}
