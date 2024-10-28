const fzf_carapace_extra_args = [--read0 --ansi --no-tmux --height=50%]
const fzf_window_first_column_max_length = 25
const fd_default_args =  [--hidden --exclude .git --exclude .cache --max-depth 9]
const fd_executable_args = [--exclude .git --exclude .cache --hidden --max-depth 5 --type x --color always '']
const tree_sitter_cmd_parser = 'nu-cmdline-parser'
const carapace_preview_description = true
# const tree_sitter_cmd_parser = null

const manpage_preview_cmd = 'man {} | col -bx | bat -l man -p --color=always --line-range :200'
const dir_preview_cmd = "eza --tree -L 3 --color=always {} | head -200"
const file_preview_cmd = "bat -n --color=always --line-range :200 {}"
const process_preview_cmd = 'ps | where pid == ({} | split row "\t" | get -i 0 | into int) | transpose Property Value | table -i false'
const remote_preview_cmd =  "dig {} | jc --dig | from json | get -i answer.0 | table -i false"
const default_preview_cmd = "if ({} | path type) == 'dir'" + $" {($dir_preview_cmd)} else {($file_preview_cmd)}"
const help_preview_cmd = "try {help {}} catch {'custom command or alias'}"
const external_tldr_cmd = "try {tldr -C {}} catch {'No doc yet'}"
const hybrid_help_cmd = ("let content = ({} | parse --regex '(?<cmd>.*[^ ])\\s*\\t\t(?<type>[^ ]*)').0
  if ($content.type | ansi strip) == 'EXTERNAL' {" +
  ($external_tldr_cmd | str replace '{}' '($content.cmd | ansi strip)') +
  "} else {" +
  ($help_preview_cmd | str replace '{}' '($content.cmd | ansi strip)') + "}"
)

const fzf_prompt_default_setting = {
  fg: '#000000'
  bg: '#c0caf5'
  symbol: ''
}
const fzf_prompt_info = {
  Carapace: { bg: '#1d8f8f' symbol: '󰳗' }
  Variable: { symbol: '󱄑' }
  Directory: { symbol: '' }
  File: { symbol: '󰈔' }
  Remote: { symbol: '󰛳' }
  Process: { symbol: '' }
  Command: { symbol: '' }
  Manpage: {bg: '#f7768e' symbol: '󰙃'}
  Internals: {bg: '#0dcf6f' symbol: '' }
  Externals: {bg: '#7aa2f7' symbol: '' }
}

use lib.nu [
  substring_from_idx
  substring_to_idx
]

def get_variable_by_name [
  name: string # $foo.bar style
] {
  let segs = $name
  | split row '.'
  mut content = {
    '$env': $env
    '$nu': $nu
  }
  for var in (scope variables) {
    $content = $content
    | default $var.value $var.name
  }
  try {
    for seg in $segs {
      if ($content | describe | str starts-with 'list') {
        $content = $content
        | get ($seg | into int)
      } else {
        $content = $content
        | get $seg
      }
    }
  } catch { {} }
  $content
}

def _quote_if_not_empty [] {
  if ($in | str trim | is-empty) {''} else {$"`($in)`"}
}

def _prompt_decorator [
  fg_color: string
  bg_color: string
  symbol: string
  type: string
] {
  let fg = {fg: $bg_color}
  let bg = {fg: $fg_color, bg: $bg_color}
  $"(ansi --escape $bg)▓▒░ ($type) ($symbol)(ansi reset)(ansi --escape $fg)(ansi reset) "
}

def _build_fzf_prompt [
  key: string
] {
  let prompt_config = $fzf_prompt_info
  | get -i $key
  | default {}
  | default $fzf_prompt_default_setting.fg fg
  | default $fzf_prompt_default_setting.bg bg
  | default $fzf_prompt_default_setting.symbol symbol

  (_prompt_decorator
    $prompt_config.fg
    $prompt_config.bg
    $prompt_config.symbol
    $key)
}

def _build_fzf_args [
  query: string
  prompt_key?: string
  preview_cmd?: string
] {
  mut args = [-q $query]
  if ($preview_cmd | is-not-empty) {
    $args = $args
    | append [--preview $preview_cmd]
  }
  if ($prompt_key | is-not-empty) {
    $args = $args
    | append [--prompt (_build_fzf_prompt $prompt_key)]
  }
  $args
}

def _padding_to_length [input_string: string length?: int] {
  let length = $length | default $fzf_window_first_column_max_length
  $input_string | fill -a l -w $length
}

def _two_column_item [
  item1: string
  item2: string
  style1?: string = (ansi yellow_reverse)
  style2?: string = (ansi purple_reverse)
] {
  $"($style1)(_padding_to_length $item1)\t\t($style2)($item2)(ansi reset)"
}

def _list_internal_commands [] {
  scope commands
  | get name
  | uniq
}

def _list_external_commands [] {
  $env.PATH
  | par-each {
    if ($in | path exists) {
      ls -s $in | get name
    } else []
  }
  | flatten
  | uniq
}

# Load full list of available manpage names from carapace zsh bridge (more thorough than apropos)
# and save to $env.MANPAGECACHE for further completion
export def update_manpage_cache [
  --force (-f) # force update if the file already exists
  --silent (-s) # print no message if set
]: nothing -> string {
  let cache_fp = $env | get -i 'MANPAGECACHE'
  if ($cache_fp | is-empty) {
    if not $silent {
      print '$env.MANPAGECACHE should be set before using this command.'
    }
    return null
  }
  if not ($cache_fp | path dirname | path exists) {
    mkdir ($cache_fp | path dirname)
  }
  if not ($cache_fp | path exists) or $force {
    carapace --macro bridge.Zsh man ''
    | from json | get values.value
    | uniq | str join "\n"
    | save -f $cache_fp
  } else {
    if not $silent {
      print 'File already exists, force rewrite by passing --force (-f) flag.'
    }
  }
  $cache_fp
}

# Do a fzf search of misc contents accroding to current command
def _complete_by_fzf [
  cmd: string # command whose arguments need to complete at present
  query: string # preceding string to search for
]: nothing -> string {
  match $cmd {
    # Search for internal commands
    _ if ($cmd in ['**' 'view']) => {
      _list_internal_commands
      | str join "\n"
      | fzf ...(_build_fzf_args $query 'Internals'
        $help_preview_cmd)
    }
    # Search for external commands
    '*^' => {
      _list_external_commands
      | str join "\n"
      | fzf ...(_build_fzf_args '' 'Externals' $external_tldr_cmd)
    }
    'man' => {
      let cache_fp = update_manpage_cache --silent
      if ($cache_fp | is-empty) {
        ''
      } else {
        open $cache_fp
        | fzf ...(_build_fzf_args $query 'Manpage' $manpage_preview_cmd)
      }
    }
    '' => {
      let dirname = ($query + (char nul)) | path dirname
      # search for executable in path
      if ($dirname | path exists) {
        fd ...$fd_executable_args $dirname
        | (fzf ...(_build_fzf_args ($query | path basename) 'File' $file_preview_cmd)
          --ansi --no-tmux --preview-window down,50%)
        | ansi strip
      } else {
        # combine internals and externals
        _list_internal_commands
        | par-each {_two_column_item $in 'NUSHELL_INTERNAL' '' (ansi green_italic)}
        | append (
          _list_external_commands
          | par-each {_two_column_item $in 'EXTERNAL' '' (ansi blue_italic)}
        )
        | str join "\n"
        | (fzf --ansi --header (_two_column_item 'Command' 'Type')
          ...(_build_fzf_args $query 'Command' $hybrid_help_cmd))
        | split row "\t"
        | get -i 0
        | default $query
        | str trim
      }
    }
    _ if ($cmd in ['z' '__zoxide_z' 'cd' 'zoxide']) => {
      fd --type=d --strip-cwd-prefix ...$fd_default_args
      | fzf ...(_build_fzf_args $query 'Directory' $dir_preview_cmd)
      | _quote_if_not_empty
    }
    "kill" => {
      ps
      | par-each {$"($in.pid)\t($in.name)"}
      | str join "\n"
      | fzf ...(_build_fzf_args $query 'Process' $process_preview_cmd)
      | split row "\t" | get -i 0
    }
    "ssh" => {
      let ssh_known_host_fp = $env.HOME | path join '.ssh' 'known_hosts'
      let parsed = $query | parse --regex '^(?<username>(.*@){0,1})(?<host_query>.*)'
      ($parsed | get 0.username | default '') + (
        if ($ssh_known_host_fp | path exists) {
          cat $ssh_known_host_fp
          | lines
          | each { $in
            | split column ' '
            | get -i 0.column1
            | str replace -r '.*\[(.+)\].*' '$1'}
          | str join "\n"
          | fzf ...(_build_fzf_args
            $parsed.0.host_query
            'Remote'
            $remote_preview_cmd)
        } else '')
    }
    _ if ($cmd in ['use' 'source']) => {
      $env.NU_LIB_DIRS
      | append $nu.default-config-dir
      | par-each {try {glob ($in | path join '**' '*.nu') } catch {[]}}
      | flatten
      | uniq
      | str join "\n"
      | fzf ...(_build_fzf_args $query 'File' ($file_preview_cmd + " -l zsh"))
    }
    _ => {
      let path_info = $query | path parse
      let base_dir = if ($path_info.parent | is-empty) {
        '.'
      } else $path_info.parent
      if (not ($base_dir | path exists)) {
        return null
      }
      fd ...$fd_default_args . ($base_dir | path expand)
      | fzf --multi ...(_build_fzf_args
        ($path_info.stem | str substring ..-3)
        'File'
        $default_preview_cmd)
      | split row "\n"
      | each {$in | _quote_if_not_empty}
      | str join ' '
    }
  }
}

def _final_spans_for_carapace [spans: list<string>] {
  $spans
  | drop 1
  | append ($spans
    | last
    | str replace -r '\w*$' '')
}

# post process for multi selected items
# select the first column if is a table
# ansi strip
def _fzf_post_process [] {
  let lines = $in
  if ($lines | is-empty) { return null }
  let lines = $lines
  | split row "\n"
  | each {$in
    | split row "\t"
    | get -i 0
    | ansi strip
    | str trim
  }
  # multiple items only triggered for files
  (if ($lines | length) > 1 {
    $lines
    | each {
      $in | _quote_if_not_empty
    }
  } else {$lines})
  | str join ' '
}

def _carapace_by_fzf [command: string spans: list<string>] {
  let query = $spans | last
  let carapace_completion = carapace $command nushell ...(_final_spans_for_carapace $spans)
  | from json
  match ($carapace_completion | length) {
    0 => null
    1 => $carapace_completion.0.value
    _ if $carapace_preview_description => (
      $carapace_completion
      | par-each {
        let value_style = ansi --escape ($in | get -i style | default {fg: yellow})
        $"($value_style)($in.value)(ansi reset)"
      }
      | str join (char nul)
      | (fzf ...(_build_fzf_args $query 'Carapace')
        ...($fzf_carapace_extra_args)
        --preview (
          $"const raw = ($carapace_completion | to json); " +
          `$"(ansi purple_reverse)Description:(ansi reset) " + ` +
          `($raw | where value == ({} | ansi strip) | get -i 0.description | default '')`
        )
        --preview-window top,10%
        ...(_carapace_git_diff_preview $spans))
      | _fzf_post_process
      | default $query
    )
    _ => ($carapace_completion
      | par-each {
        let value_style = ansi --escape ($in | get -i style | default {fg: yellow})
        (_two_column_item
          $in.value # drop items with no value field
          ($in | get -i description | default '')
          $value_style
          (ansi purple_italic))
      }
      | str join (char nul)
      | (fzf ...(_build_fzf_args $query 'Carapace')
        --header (_two_column_item 'Value' 'Description')
        ...($fzf_carapace_extra_args)
        ...(_carapace_git_diff_preview $spans))
      | _fzf_post_process
      | default $query
    )
  }
}

def _env_by_fzf [
  query: string
  use_carapace?: bool = false
] {
  if not ('$' in $query) {
    return null
  }
  let parsed = $query | parse --regex '(?<prefix>.*)(?<true_query>\$[^$]*)'
  let prefix = $parsed.0.prefix
  let true_query = $parsed.0.true_query
  if $use_carapace {
    let res = _carapace_by_fzf 'get-env' [get-env ($true_query | str substring 1..)]
    if ($res | is-empty) {$query} else {$prefix + '$env.' + $res}
  } else {
    let segs = $true_query | split row '.'
    let seg_prefix = $segs | drop 1 | append '' | str join '.'
    let content = get_variable_by_name $seg_prefix
    let res = (
      match ($content | describe | str substring 0..4) {
        'list<' => {
          0..(($content | length) - 1)
          | each {$in | into string}
        }
        'recor' => {
          $content
          | columns
        }
        'table' => {
          $content
          | get ($content | columns | first)
        }
        _ => {
          []
        }
      }
      | str join "\n"
      | (
        fzf ...(
          _build_fzf_args ($segs | last)
          'Variable'
          (
            $"const raw = ($content | to json); " +
            `(match ($raw | describe | str substring ..4) {
            'list<' => {$raw | get -i ({} | into int)},
            _ => {$raw | table -i false -t basic | find {}
            | each {let segs = $in | split row '|'
            {$'name': ($segs | get 1)
            $'value': ($segs | get (($segs | length) - 2))}}
            | table -i false}})
            | str replace --regex '((│(\s*\w+\s*))*│)\n├' $"(ansi green)$1(ansi reset)\n├"
            | str replace --regex --all '([╭├][┬┼─]+[┤╮])' $'(ansi green)$1(ansi reset)'`
          )
        )
        --tmux center,90%,50%
        --preview-window right,70%
      )
    )
    if ($res | is-empty) {$query} else {$prefix + $seg_prefix + $res}
  }
}

def _carapace_git_diff_preview [
  spans: list<string>
] {
  match $spans.0 {
    'git' if ($spans | get -i 1 | default '') in [
      'add' 'show' 'diff' 'stage'
    ] => [--preview
      r#'let fp = ({} | split row "\t" | first | str trim); if ($fp | path exists) {git diff $fp | delta} else {git log --color}'#
      --height=100%
      --multi
      '--preview-window=right,65%'
      '--tmux=center,80%,80%'
    ]
    _ => []
  }
}

# if the current command is an alias, get it's expansion
def _expand_alias_if_exist [cmd: string] {
  scope aliases
  | where name == $cmd
  | get -i 0.expansion
  | default $cmd
}

# This command is for customized completer to get true content for completion
# example1: `(foo | bar baz` should => [bar baz]
# example2: `(foo | (b` should => [b]
# also expands aliases
def _trim_spans [
  spans: list<string> # original spans of space splited terms of current command, provided by nushell
] {
  let trimmed = ($spans
    # reversely take until ( or | or { or ; is found
    | reverse
    | take until {|r| $r =~ '[ \n]*[|({;][ \n]*'}
    | reverse
  )

  if ($trimmed | is-empty) {
    [''] # never empty
  } else {
    $trimmed
    | skip 1
    | prepend (_expand_alias_if_exist $trimmed.0
      | split row ' ')
  }
}

# Completion done by external carapace command
# specially treated when something like `vim **` is present
export def carapace_by_fzf [
  raw_spans: list<string> # list of commandline arguments to trigger `carapace <command> nushell ...($spans)`
] {
  # return ($raw_spans | each {'========' + $in + '========'})
  let spans = _trim_spans $raw_spans
  let query = $spans | last
  let res = try {
    match $spans.0 {
      _ if "$" in $query => {
        _env_by_fzf $query
      }
      _ if ($query | str substring (-2)..) in ['**' '*^'] => {
        _complete_by_fzf $spans.0 $query
      }
      _ if $spans.0 == 'which' or ($spans | length) == 1 => {
        _complete_by_fzf '' $query
      }
      '__zoxide_z' => {
        _complete_by_fzf 'cd' $query
      }
      'man' => {
        _complete_by_fzf 'man' $query
      }
      '__zoxide_zi' => {
        $'(zoxide query --interactive ...($spans | skip 1) | str trim -r -c "\n")'
      }
      _ => {
        _carapace_by_fzf $spans.0 $spans
      }
    }
  } catch { null }
  match $res {
    null => null # continue with built-in completer, may cause another trigger of this completer
    '' => [$query] # nothing changes
    _ => [({description: 'From customized external completer'} | default $res 'value')]
  }
}

# Manually triggered completion inline replacement of the commandline string
# override default behaviors for some commands like kill ssh zoxide which is defined in _complete_by_fzf
export def complete_line_by_fzf [] {
  let cmd_raw = commandline
  let cursor_pos = commandline get-cursor
  let suffix = $cmd_raw | str substring -g $cursor_pos..
  let cmd_before_pos = $cmd_raw | str substring -g ..($cursor_pos - 1)
  let cursor_pos = $cmd_before_pos | str length # in byte not in grapheme
  let parsed = (if ($tree_sitter_cmd_parser | is-not-empty) {
    # get current command for completion, output in format:
    # command start offset\n
    # command end offset\n
    let start_offset = $cmd_raw
    | ^$tree_sitter_cmd_parser --kind command --insert --offset $cursor_pos
    | lines
    | get -i 0
    | default 0
    | into int
    let cmd_with_query = $cmd_raw
    | str substring $start_offset..($cursor_pos - 1)
    | str trim --left
    let first_space = $cmd_with_query | str index-of ' '
    let first_enter =  $cmd_with_query | str index-of "\n"
    let first_split = match [$first_space $first_enter] {
      [-1, _] => $first_enter
      [_, -1] => $first_space
      _ => { [$first_space $first_enter] | math min }
    }
    let last_space = $cmd_with_query | str index-of -e ' '
    let last_enter =  $cmd_with_query | str index-of -e "\n"
    let last_split = match [$last_space $last_enter] {
      [-1, _] => $last_enter
      [_, -1] => $last_space
      _ => { [$last_space $last_enter] | math max }
    }
    {
      prefix: ($cmd_raw | substring_to_idx ($start_offset - 1))
      query: ($cmd_with_query | substring_from_idx ($last_split + 1))
      cmd: ($cmd_with_query | substring_to_idx $last_split)
      cmd_head: ($cmd_with_query | substring_to_idx ($first_split - 1))
    }
  } else {
      let parsed_raw = $cmd_before_pos
      | str replace --all "\n" (char nul) # workarounds for bugs of parse command
      | parse --regex '^(?<prefix>(.*[(|{;])*)(?<cmd>[ \x00]*([^ ]+\s+)*)(?<query>[^\x00 |({;]*)$' #\x00 for nul character
      | get -i 0

      $parsed_raw
      | default ($parsed_raw.cmd
        | str trim
        | split row ' '
        | get -i 0 | default ''
        | str replace --all (char nul) '') 'cmd_head'
    })
  let query = $parsed.query
  let fzf_res = try {
    if ('$' in $query) {
      _env_by_fzf $query
    } else {
      _complete_by_fzf $parsed.cmd_head $query
    }
  } catch { $query }
  let completed_before_pos = $parsed.prefix + $parsed.cmd + $fzf_res
  | str replace --all (char nul) "\n"
  commandline edit --replace ($completed_before_pos + $suffix)
  commandline set-cursor ($completed_before_pos | str length -g)
}
