const kb_config = {
  name: matchit_keybinding
  modifier: none
  keycode: 'char_%'
  mode: [vi_normal]
  event: {
    send: executehostcommand
    cmd: matchit_exec
  }
}

use lib.nu substring_to_idx

export def matchit_exec [] {
    let cursor_pos = commandline get-cursor
    let cmd_raw = commandline
    let offset = $cmd_raw | substring_to_idx -g ($cursor_pos - 1) | str length # grapheme to byte
    let matched_offset = $cmd_raw
      | ^nu-cmdline-parser --matchit --offset $offset
      | lines
      | get -i 0
      | default 0
      | into int
    let matched_grapheme = $cmd_raw
      | substring_to_idx ($matched_offset - 1)
      | str length -g
    commandline set-cursor $matched_grapheme
}

export def --env "set matchit_keybinding" [] {
  $env.config.keybindings = $env
  | get -i config.keybindings | default []
  | append $kb_config
}