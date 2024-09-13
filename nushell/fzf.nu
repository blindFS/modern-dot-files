const fzf_carapace_extra_args = [--read0 --ansi --no-tmux --height=50%]
const fzf_window_first_column_max_length = 36
const dir_preview_cmd = "eza --tree -L 3 --color=always {} | head -200"
const file_preview_cmd = "bat -n --color=always --line-range :200 {}"
const default_preview_cmd = "if ({} | path type) == 'dir'" + $" {($dir_preview_cmd)} else {($file_preview_cmd)}"
const help_preview_cmd = "try {help {}} catch {'custom command or alias'}"
const external_tldr_cmd = "try {tldr -C {}} catch {'No doc yet'}"
const hybrid_help_cmd = ("let content = ({} | parse --regex '(?<cmd>.*[^ ])\\s*\\t\t(?<type>[^ ]*)').0
if ($content.type | ansi strip) == 'EXTERNAL' {"
    + ($external_tldr_cmd | str replace '{}' '($content.cmd | ansi strip)')
    + "} else {"
    + ($help_preview_cmd | str replace '{}' '($content.cmd | ansi strip)')
    + "}"
)
const fzf_prompt_default_setting = {
    fg: '#000000'
    bg: '#7aa2f7'
    symbol: 'FZF'
}
const fzf_prompt_info = {
    carapace: {
        bg: '#c0caf5'
        symbol: 󰳗
    }
    variable: { symbol: 󱄑 }
    directory: { symbol:  }
    file: { symbol: 󰈔 }
    remote: { symbol: 󰛳 }
    process: { symbol:  }
    command: { symbol:  }
}

export def get_variable_by_name [
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

def quote_if_not_empty [s: string] {
    if ($s | str trim | is-empty) {''} else {$"`($s)`"}
}

def build_fzf_prompt [
    key: string
] {
    let prompt_config = $fzf_prompt_info
    | get -i $key
    | default {}
    | default $fzf_prompt_default_setting.fg fg 
    | default $fzf_prompt_default_setting.bg bg
    | default $fzf_prompt_default_setting.symbol symbol

    (prompt_decorator
    $prompt_config.fg
    $prompt_config.bg
    $prompt_config.symbol
    false)
}

def build_fzf_args [
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
        | append [--prompt (build_fzf_prompt $prompt_key)]
    }
    $args
}

def padding_to_length [input_string: string length?: int] {
    let length = $length | default $fzf_window_first_column_max_length
    $input_string | fill -a l -w $length
}

def _list_internal_commands [] {
    scope commands
    | get name
    | uniq
}

def _list_external_commands [] {
    $env.PATH
    | each {|f| if ($f | path exists) {
        ls -s $f | get name
    } else []}
    | flatten
    | uniq
}

export def _complete_by_fzf [cmd: string query: string] {
    match $cmd {
        # Search for internal commands
        _ if ($cmd in ['**' 'view']) => {
            _list_internal_commands
            | str join "\n"
            | fzf ...(build_fzf_args $query 'command' $help_preview_cmd)
        }
        # Search for external commands
        "*^" => {
            _list_external_commands
            | str join "\n"
            | fzf ...(build_fzf_args "" 'command' $external_tldr_cmd)
        }
        # combine internals and externals
        '' => {
            _list_internal_commands
            | each {|in| $"(padding_to_length $in)\t\t(ansi green_italic)NUSHELL_INTERNAL(ansi reset)"}
            | append (
                _list_external_commands
                | each {|ext| $"(padding_to_length $ext)\t\t(ansi blue_italic)EXTERNAL(ansi reset)"}
            )
            | str join "\n"
            | (fzf --ansi --header $"(padding_to_length "Command")\t\tType"
                ...(build_fzf_args $query 'command' $hybrid_help_cmd))
            | split row "\t"
            | get -i 0
            | default $query
            | str trim
        }
        _ if ($cmd in ['z' '__zoxide_z' 'cd' 'zoxide' 'ls' 'eza']) => {
            let res = (fd --type=d --hidden --strip-cwd-prefix --exclude .git --exclude .cache --max-depth 9
                | fzf ...(build_fzf_args $query 'directory' $dir_preview_cmd))
            quote_if_not_empty $res
        }
        "kill" => {
            ps
            | each {|r| $"($r.pid)\t($r.name)"}
            | str join "\n"
            | fzf ...(build_fzf_args $query 'process' 'ps | where pid == ({} | split row "\t" | get -i 0 | into int) | transpose')
            | split row "\t" | get -i 0
        }
        "ssh" => {
            cat ~/.ssh/known_hosts
            | lines
            | each { |line| $line
                | split column ' '
                | get -i 0.column1
                | str replace -r '.*\[(.+)\].*' '$1'}
            | str join "\n"
            | fzf ...(build_fzf_args $query 'remote' "dig {} | jc --dig | from json | get answer | get -i 0")
        }
        _ if ($cmd in ['use' 'source']) => {
            $env.NU_LIB_DIRS
            | append $nu.default-config-dir
            | each {|dir| try {glob ($dir | path join '**' '*.nu') } catch {[]}}
            | flatten
            | uniq
            | str join "\n"
            | fzf ...(build_fzf_args $query 'file' ($file_preview_cmd + " -l zsh"))
        }
        _ => {
            fzf --multi ...(build_fzf_args $query 'file' $default_preview_cmd)
            | split row "\n"
            | each {|line| quote_if_not_empty $line}
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

def _carapace_by_fzf [command: string spans: list<string>] {
    let query = $spans | last
    let carapace_completion = carapace $command nushell ...(_final_spans_for_carapace $spans)
        | from json
    match ($carapace_completion | length) {
        0 => null
        1 => $carapace_completion.0.value
        _ => ($carapace_completion
            | each {|item|
                let value_style = ansi --escape ($item | get -i style | default {fg: yellow})
                $"($value_style)(padding_to_length $item.value)(ansi reset)(ansi purple_bold)\t\t($item
                    | get -i description)(ansi reset)"}
            | str join (char nul)
            | (fzf ...(build_fzf_args $query 'carapace')
                --header $"(padding_to_length "Value")\t\tDescription"
                ...($fzf_carapace_extra_args))
            | split row "\t"
            | get -i 0
            | default $query
            | ansi strip
            | str trim
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
        let content = get_variable_by_name $true_query
        let res = (if ($content | describe | str starts-with 'list') {
            0..(($content | length) - 1)
            | each {|n| $n | into string}
        } else {
            $content
            | columns
        })
        | str join "\n"
        | (fzf ...(build_fzf_args ($segs | last)
            'variable' ("print r#'" + ($content | table -i false) + "'#"))
            --tmux center,90%,50%
            --preview-window right,70%
        )
        if ($res | is-empty) {$query} else {$prefix + $seg_prefix + $res}
    }
}

# if the current command is an alias, get it's expansion
def expand_alias_if_exist [cmd: string] {
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
        | prepend (expand_alias_if_exist $trimmed.0
            | split row ' ')
    }
}

# Completion done by external carapace command
# specially treated when something like `vim **` is present
export def carapace_by_fzf [
    raw_spans: list<string> # list of commandline arguments to trigger `carapace <command> nushell ...($spans)`
] {
    # return ($raw_spans | each {|it| $"=====($it)====="})
    let spans = _trim_spans $raw_spans
    let query = $spans | last
    let res = (
        match $query {
            _ if "$" in $query => {
                _env_by_fzf $query
            }
            _ if $query in ['**' '*^'] => {
                _complete_by_fzf $spans.0 ''
            }
            _ if ($spans | length) == 1 => {
                _complete_by_fzf '' $query
            }
            _ => {
                _carapace_by_fzf $spans.0 $spans
        }
    })
    match $res {
        null => null # continue with built-in completer, may cause another trigger of this completer
        '' => [$query] # nothing changes
        _ => [({description: 'From customized external completer'}
                | default $res 'value')]
    }
}

# Manually triggered completion inline replacement of te commandline string
# override default behaviors for some commands like kill ssh zoxide which is defined in _complete_by_fzf
export def complete_line_by_fzf [] {
    let cmd_raw = commandline
    let cursor_pos = commandline get-cursor
    let initial_length = $cmd_raw | str length
    let suffix = $cmd_raw | str substring $cursor_pos..
    let cmd_before_pos = $cmd_raw | str substring ..($cursor_pos - 1)
    let parsed = $cmd_before_pos
        | str replace --all "\n" (char nul) # workarounds for bugs of parse command
        | parse --regex '^(?<prefix>(.*[(|{;])*)(?<cmd>[ \x00]*([^ ]+\s+)*)(?<query>[^\x00 |({;]*)$' #\x00 for nul character
        | get -i 0
    let cmd_head = $parsed.cmd
        | str trim
        | split row ' '
        | get -i 0 | default ''
        | str replace --all (char nul) ''
    let query = $parsed.query
    let fzf_res = (
        if ('$' in $query) {
            _env_by_fzf $query
        } else {
            _complete_by_fzf $cmd_head $query
        })
    let completed_before_pos = $parsed.prefix + $parsed.cmd + $fzf_res
        | str replace --all (char nul) "\n"
    commandline edit --replace ($completed_before_pos + $suffix)
    commandline set-cursor ($completed_before_pos | str length)
}
