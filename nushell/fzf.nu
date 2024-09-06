def quote_if_not_empty [s:string] {
    if (($s | str trim) == "") {""} else {$"`($s)`"}
}

def fzf_with_query [query:string, preview_cmd?:string] {
    if ($preview_cmd == null) or ($preview_cmd == "") {
        fzf -q $query
    } else {
        fzf -q $query --preview $preview_cmd
    }
}

def complete_variable_by_fzf [query:string] {
    let variable_list = ($query | split row ".")
    let var_query = ($variable_list | last)
    let var_view_cmd = ($variable_list | range ..-2 | str join ".")
    if ($var_view_cmd | is-empty) {
        return (
            scope variables
            | get name
            | append ['$env.' '$nu.']
            | str join "\n"
            | fzf_with_query $var_query)
    }
    let preview_cmd = $"if \(($var_view_cmd).{} | describe\) == 'closure' {view source ($var_view_cmd).{} | bat -l zsh -n --color=always} else {($var_view_cmd).{}}"
    ($var_view_cmd + "." +
    (nu -c $"($var_view_cmd) | to json"
    | from json
    | columns
    | str join "\n"
    | fzf_with_query $var_query $preview_cmd))
}

def get_completed_command_by_fzf [cursor_pos:int] {
    let dir_preview_cmd = "eza --tree -L 3 --color=always {} | head -200"
    let file_preview_cmd = "bat -n --color=always --line-range :200 {}"
    let default_preview_cmd = "if ({} | path type) == 'dir'" + $" {($dir_preview_cmd)} else {($file_preview_cmd)}"
    let help_preview_cmd = "try {help {}} catch {'custom command or alias'}"

    let terms = (commandline | str substring ..($cursor_pos - 1) | split row " ")
    let suffix = (commandline | str substring $cursor_pos..)
    let cmd = ($terms | first)
    let query = ($terms | last)
    let cmd_without_query = ($terms | range ..-2 | str join " ")
    # shell variable search with preview
    if ($query | str starts-with "$") {
        let trimmed_cmd_prefix = ($cmd_without_query + " " | str trim --left)
        return $"($trimmed_cmd_prefix)(complete_variable_by_fzf $query)($suffix)"
    }
    (if ($query == $cmd) {
        match $cmd {
            "_" => {
                $env.PATH | each {|f| ls -s $f | get name}
                | flatten | uniq | str join "\n"
                | fzf_with_query "" "try {tldr -C {}} catch {'No doc yet'}"
            },
            _ => {
                help commands | get name
                | str join "\n"
                | fzf_with_query $query $help_preview_cmd
            }
        }
    } else {
        $cmd_without_query + " " + match $cmd {
            "cd" => {
                let res = (fd --type=d --hidden --strip-cwd-prefix --exclude .git --exclude .cache --max-depth 9
                                | fzf_with_query $query $dir_preview_cmd)
                quote_if_not_empty $res
            },
            "view" => {
                scope commands
                | get name
                | uniq
                | str join "\n"
                | fzf_with_query $query $help_preview_cmd
            }
            "ssh" => {
                cat ~/.ssh/known_hosts
                | lines
                | each { |line| $line | split column " " | get column1 | get -i 0 | str replace -r '.*\[(.+)\].*' '$1'}
                | str join "\n"
                | fzf_with_query $query "dig {} | jc --dig | from json | get answer | get -i 0"
            },
            _ if ($cmd in ['use' 'source']) => {
                $env.NU_LIB_DIRS
                | append $nu.default-config-dir
                | each {|dir| try {glob ($dir | path join "**" "*.nu") } catch {[]}}
                | flatten
                | uniq
                | str join "\n"
                | fzf_with_query $query ($file_preview_cmd + " -l zsh")
            }
            _ => {
                let res = (fzf_with_query $query $default_preview_cmd)
                quote_if_not_empty $res
            }
        }
    }) + $suffix
}

export def complete_by_fzf [] {
    let initial_length = (commandline | str length)
    let cursor_pos = (commandline get-cursor)
    let completed_command = (get_completed_command_by_fzf $cursor_pos)
    let finial_pos = ($completed_command | str length) - $initial_length + $cursor_pos
    commandline edit --replace $completed_command
    commandline set-cursor $finial_pos
}