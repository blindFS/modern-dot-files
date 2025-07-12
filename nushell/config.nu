# env-vars
source style.nu
$env.PATH = $env.PATH
| split row (char esep)
| append '/usr/local/bin'
| append ($env.HOME | path join ".elan" "bin")
| prepend ($env.HOME | path join ".cargo" "bin")
| prepend ($env.HOME | path join ".local" "bin")
| uniq
$env.FZF_DEFAULT_COMMAND = "fd --hidden --strip-cwd-prefix --exclude .git --exclude .cache --max-depth 9"
$env.CARAPACE_LENIENT = 1
$env.CARAPACE_BRIDGES = 'zsh'
$env.MANPAGER = "col -bx | bat -l man -p"
$env.MANPAGECACHE = ($nu.default-config-dir | path join 'mancache.txt')
$env.RUST_BACKTRACE = 1
$env.TOPIARY_LANGUAGE_DIR = ($env.XDG_CONFIG_HOME | path join topiary languages)

use fzf.nu [
  carapace_by_fzf
  complete_line_by_fzf
  update_manpage_cache
  atuin_menus_func
]
use sesh.nu sesh_connect
source themes/tokyonight_night.nu

$env.config.completions.external.completer = {|span| carapace_by_fzf $span }
$env.config.edit_mode = "vi"
$env.config.highlight_resolved_externals = true
$env.config.history.file_format = "sqlite"
$env.config.history.max_size = 10000
$env.config.show_banner = false
$env.config.table.header_on_separator = true
$env.config.table.index_mode = 'auto'
$env.config.render_right_prompt_on_last_line = true

$env.config.cursor_shape = {
  emacs: line # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (line is the default)
  vi_insert: line # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (block is the default)
  vi_normal: block # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (underscore is the default)
}

$env.config.explore = {
  status_bar_background: {bg: $extra_colors.explore_bg fg: $extra_colors.explore_fg}
  command_bar_text: {fg: $extra_colors.explore_fg}
  highlight: {fg: "black" bg: "yellow"}
  status: {
    error: {fg: "white" bg: "red"}
    warn: {}
    info: {}
  }
  selected_cell: {bg: light_blue fg: "black"}
}

$env.config.menus ++= [
  # Configuration for default nushell menus
  # Note the lack of source parameter
  {
    name: my_history_menu
    only_buffer_difference: false
    marker: ''
    type: {layout: ide}
    style: {}
    source: (
      atuin_menus_func
      (
        prompt_decorator
        $extra_colors.prompt_symbol_color
        'light_blue'
        '▓▒░ Ctrl-d to del '
        false
      )
    )
  }
  {
    name: completion_menu
    only_buffer_difference: false
    marker: (prompt_decorator $extra_colors.prompt_symbol_color "yellow" "")
    type: {
      layout: columnar
      columns: 4
      col_width: 20 # Optional value. If missing all the screen width is used to calculate column width
      col_padding: 2
    }
    style: {
      text: $extra_colors.menu_text_color
      selected_text: {attr: r}
      description_text: yellow
      match_text: {attr: u}
      selected_match_text: {attr: ur}
    }
  }
  {
    name: history_menu
    only_buffer_difference: false
    marker: (prompt_decorator $extra_colors.prompt_symbol_color "light_blue" "")
    type: {
      layout: list
      page_size: 30
    }
    style: {
      text: $extra_colors.menu_text_color
      selected_text: light_blue_reverse
      description_text: yellow
    }
  }
]

$env.config.keybindings ++= [
  {
    name: history_menu
    modifier: control
    keycode: char_h
    mode: [emacs vi_insert vi_normal]
    event: {send: menu name: my_history_menu}
    # event: {send: menu name: ide_completion_menu}
  }
  {
    name: sesh
    modifier: control
    keycode: char_s
    mode: [emacs vi_insert vi_normal]
    event: {
      send: executehostcommand
      cmd: sesh_connect
    }
  }
  {
    name: vicmd_history_menu
    modifier: shift
    keycode: char_k
    mode: vi_normal
    event: {send: menu name: my_history_menu}
  }
  {
    name: cut_line_to_end
    modifier: control
    keycode: char_k
    mode: [emacs vi_insert]
    event: {edit: cuttoend}
  }
  {
    name: cut_line_from_start
    modifier: control
    keycode: char_u
    mode: [emacs vi_insert]
    event: {edit: cutfromstart}
  }
  {
    name: fuzzy_complete
    modifier: control
    keycode: char_t
    mode: [emacs vi_normal vi_insert]
    event: {
      send: executehostcommand
      cmd: complete_line_by_fzf
    }
  }
]

# load scripts
use starship.nu
use scripts/extractor.nu extract
use auto-pair.nu *
set auto_pair_keybindings
use matchit.nu *
set matchit_keybinding
source zoxide.nu
source nix.nu
source auth/llm.nu
source atuin.nu

# alias
alias vim = nvim
alias boc = brew outdated --cask --greedy
alias ll = ls -al
alias c = zi
alias less = less -R
