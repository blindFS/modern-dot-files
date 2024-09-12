const fzf_completion_value_max_length = 36

def quote_if_not_empty [s: string] {
    if (($s | str trim) | is-empty) {''} else {$"`($s)`"}
}

def fzf_with_query [query: string preview_cmd?: string] {
    if ($preview_cmd | is-empty) {
        fzf -q $query
    } else {
        fzf -q $query --preview $preview_cmd
    }
}

def _complete_by_fzf [cmd: string query: string] {
    let dir_preview_cmd = "eza --tree -L 3 --color=always {} | head -200"
    let file_preview_cmd = "bat -n --color=always --line-range :200 {}"
    let default_preview_cmd = "if ({} | path type) == 'dir'" + $" {($dir_preview_cmd)} else {($file_preview_cmd)}"
    let help_preview_cmd = "try {help {}} catch {'custom command or alias'}"

    match $cmd {
        "**^" => {
            $env.PATH | each {|f| ls -s $f | get name}
            | flatten | uniq | str join "\n"
            | fzf_with_query "" "try {tldr -C {}} catch {'No doc yet'}"
        }
        _ if ($cmd in ['**' '' 'view']) => {
            scope commands
            | get name
            | uniq
            | str join "\n"
            | fzf_with_query $query $help_preview_cmd
        }
        _ if ($cmd in ['z' '__zoxide_z' 'cd' 'zoxide' 'ls' 'eza']) => {
            let res = (fd --type=d --hidden --strip-cwd-prefix --exclude .git --exclude .cache --max-depth 9
                            | fzf_with_query $query $dir_preview_cmd)
            quote_if_not_empty $res
        }
        "kill" => {
            ps
            | each {|r| $"($r.pid)\t($r.name)"}
            | str join "\n"
            | fzf_with_query $query 'ps | where pid == ({} | split row "\t" | get -i 0 | into int) | transpose'
            | split row "\t" | get -i 0
        }
        "ssh" => {
            cat ~/.ssh/known_hosts
            | lines
            | each { |line| $line | split column ' ' | get column1 | get -i 0 | str replace -r '.*\[(.+)\].*' '$1'}
            | str join "\n"
            | fzf_with_query $query "dig {} | jc --dig | from json | get answer | get -i 0"
        }
        _ if ($cmd in ['use' 'source']) => {
            $env.NU_LIB_DIRS
            | append $nu.default-config-dir
            | each {|dir| try {glob ($dir | path join '**' '*.nu') } catch {[]}}
            | flatten
            | uniq
            | str join "\n"
            | fzf_with_query $query ($file_preview_cmd + " -l zsh")
        }
        _ => {
            let res = fzf_with_query $query $default_preview_cmd
            quote_if_not_empty $res
        }
    }
}

def _final_spans_for_carapace [
    spans_without_last: list<string> # Example for command (where | stands for cursor) `for bar baz|hello world`, this value should be [for bar]
    query: string # Example for command `for bar baz|hello world`, this value should be `baz`
] {
    $spans_without_last
    | append ($query
        | str replace -r '\w*$' '')
}

def _carapace_by_fzf [command: string spans_without_last: list<string> query: string] {
    let carapace_completion = carapace $command nushell ...(_final_spans_for_carapace $spans_without_last $query)
        | from json
    if ($carapace_completion | is-empty) {
        null
    } else {
        $carapace_completion
        | each {|item|
            let value_style = ansi --escape ($item | get -i style | default {fg: yellow})
            $"($value_style)($item.value | fill -a l -w $fzf_completion_value_max_length)(ansi
                    reset)(ansi purple_bold)\t\t($item | get -i description)(ansi reset)"}
        | str join (char nul)
        | fzf --read0 --ansi -q $query --header $"("Value" | fill -a l -w $fzf_completion_value_max_length)\t\tDescription"
        | split row "\t"
        | get -i 0
        | default $query
        | ansi strip
        | str trim
    }
}

def _carapace_env_by_fzf [query: string] {
    let prefix = $query | split row '$' | first
    let true_query = $query | split row '$' | last
    let res = (_carapace_by_fzf
        'get-env'
        [get-env]
        $true_query)
    if ($res | is-empty) {$query} else {$prefix + '$env.' + $res}
}

# Completion done by external carapace command
# specially treated when something like `vim **` is present
export def carapace_by_fzf [
    raw_spans: list<string> # list of commandline arguments to trigger `carapace <command> nushell ...($spans)`
] { # remove the leading pipe char
    let spans = (
        (if $raw_spans.0 == '|' {
            $raw_spans | skip 1
        } else $raw_spans)
        # remove the external sign
        | update 0 {|cmd| $cmd | str trim --left --char '^'}
    )
    # if the current command is an alias, get it's expansion
    let expanded_alias = (scope aliases
        | where name == $spans.0 | get -i 0 | get -i expansion)
    # overwrite
    let spans = (if $expanded_alias != null  {
        # put the first word of the expanded alias first in the span
        $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
    } else {
        $spans
    })
    if ($spans | is-empty) {
        []
    } else {
        let spans_without_last = $spans | drop 1
        let query = $spans | last
        let res = (
            match $query {
            _ if ("$" in $query) => {
                _carapace_env_by_fzf $query
            }
            _ if ($query in ['**' '**^']) => {
                _complete_by_fzf $spans.0 ''
            }
            _ => {
                _carapace_by_fzf $spans.0 $spans_without_last $query
            }
        })
        if ($res | is-empty) {
            null
        } else {
            [({description: ''}
            | default $res 'value')]
        }
    }
}

# Manually triggered completion inline replacement of te commandline string
export def complete_line_by_fzf [] {
    let cmd_raw = commandline
    let cursor_pos = commandline get-cursor
    let initial_length = $cmd_raw | str length
    let suffix = $cmd_raw | str substring $cursor_pos..
    let cmd_before_pos = $cmd_raw | str substring ..($cursor_pos - 1)
    let segs_by_pipe = $cmd_before_pos | split row '|'
    let piped_prefix = $segs_by_pipe | drop 1 | append '' | str join '|'
    # mininal unit of spans to complete
    let trailing_spaces = ($segs_by_pipe | last | parse -r '^( *)[^ ]*' | get -i 0.capture0)
    let raw_spans = $segs_by_pipe | last | str trim --left | split row ' '
    let query = $raw_spans | last
    let spans_without_last = $raw_spans | drop 1
    let new_seg_str = ($spans_without_last
        | append (if "$" in $query {
            _carapace_env_by_fzf $query
        } else {
            _complete_by_fzf (if ($raw_spans | length) > 1
                { $raw_spans.0 } else '') $query
        })
        | str join ' ')
    commandline edit --replace ($piped_prefix + $trailing_spaces + $new_seg_str + $suffix)
    commandline set-cursor ($piped_prefix + $trailing_spaces + $new_seg_str | str length)
}
