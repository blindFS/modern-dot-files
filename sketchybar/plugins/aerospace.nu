#!/usr/bin/env nu

const app_icons = {
    arc: 󰣇
    safari: 󰀹
    code: 󰨞
    wezterm: 
    emacs: 
    finder: 󰀶
    mail: 
    photos: 
    preview: 
    books: 
    'app store': 
    'system settings': 󰒓
}

const focused_border_color = 0xff0dcf6f
const default_border_color = 0x88ffffff
const animation_frames = 60

def modify_args_per_workspace [sid: string focused_sid: string] {
    let windows = (aerospace list-windows --workspace $sid
                        | lines
                        | each {|it| $it
                                | split row '|'
                                | get 1
                                | str trim
                                | str downcase
                                })
    let icons = $windows
    | each {|name| $app_icons
            | get -i $name
            | default ''}
    | uniq
    | str join ' '
    | fill -c '░' -w 1

    let extra = (if $sid == $focused_sid
        {{
            highlight: on
            border_color: $focused_border_color
        }}
        else {{
            highlight: off
            border_color: $default_border_color
        }})

    ['--animate' 'sin' $animation_frames '--set' $"space.($sid)"]
    | append (if (($windows | is-empty) and ($sid != $focused_sid)) {
        "drawing=off"
    } else {
        ["drawing=on" $"icon=($icons)" $"icon.highlight=($extra.highlight)"]
    })
    | append $"background.border_color=($extra.border_color)"
}

def modify_workspaces [last_sid: string] {
    let focused_sid = (aerospace list-workspaces --focused)
    let ids_to_modify = (
        if ($last_sid | is-empty)
            {(aerospace list-workspaces --all | lines)}
        else {
            [$focused_sid $last_sid]
        }
    )
    let batched_args = ($ids_to_modify
    | uniq
    | each {|sid| modify_args_per_workspace $sid $focused_sid}
    | flatten
    | append ["--set" $env.NAME $"label=($focused_sid)"])
    sketchybar ...($batched_args)
}

match $env.SENDER {
    _ => {
        # use listener's label to store last focused space id
        let last_sid = (sketchybar --query $env.NAME | from json | get label.value)
        modify_workspaces $last_sid
    }
}