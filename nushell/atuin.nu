# Source this in your ~/.config/nushell/config.nu
$env.ATUIN_SESSION = (atuin uuid)
hide-env -i ATUIN_HISTORY_ID
# Magic token to make sure we don't record commands run by keybindings
let ATUIN_KEYBINDING_TOKEN = $"# (random uuid)"
let _atuin_pre_execution = {||
  if ($nu | get -i history-enabled) == false {
    return
  }
  let cmd = (commandline)
  if ($cmd | is-empty) {
    return
  }
  if not ($cmd | str starts-with $ATUIN_KEYBINDING_TOKEN) {
    $env.ATUIN_HISTORY_ID = (atuin history start -- $cmd)
  }
}
let _atuin_pre_prompt = {||
  let last_exit = $env.LAST_EXIT_CODE
  if 'ATUIN_HISTORY_ID' not-in $env {
    return
  }
  with-env { ATUIN_LOG: error } {
    do {atuin history end $'--exit=($last_exit)' -- $env.ATUIN_HISTORY_ID} | complete
  }
  hide-env ATUIN_HISTORY_ID
}
$env.config = ($env | default {} config).config
$env.config = ($env.config | default {} hooks)
$env.config = (
  $env.config | upsert hooks (
    $env.config.hooks
    | upsert pre_execution (
      $env.config.hooks | get -i pre_execution | default [] | append $_atuin_pre_execution
    )
    | upsert pre_prompt (
      $env.config.hooks | get -i pre_prompt | default [] | append $_atuin_pre_prompt
    )
  )
)
$env.config = ($env.config | default [] keybindings)

const atuin_refresh_cmd = r#'
  atuin history list --reverse false --cwd --cmd-only --print0
  | split row (char nul) | uniq
  | par-each {$in | nu-highlight}
  | str join (char nul)'#

# list highlighted history within current directory
def atuin_list_history [] {
  nu -c $atuin_refresh_cmd
}

const atuin_delete_cmd = r##'atuin search --search-mode full-text --delete $"({} | ansi strip)"'##

def atuin_menus_func [
  prompt: string
]: nothing -> closure {
  {|buffer, position|
    { # only history of current directory
      value: (
        atuin_list_history
        | (
          fzf --read0 --ansi -q $buffer
          --bind $"ctrl-d:execute\(($atuin_delete_cmd)\)+reload\(($atuin_refresh_cmd)\)"
          --no-tmux --height 40%
          --prompt $prompt
        )
        | ansi strip
      )
    }
  }
}
