#!/usr/bin/env nu

const app_icons = {
    'app store': 
    'steam helper':  󰓓
    'system settings': 󰒓
    arc: 󰣇
    books: 
    calculator: 
    calendar: 
    code: 󰨞
    dictionary: 
    discord: 󰙯
    emacs: 
    finder: 󰀶
    gimp: 
    mail: 
    maps: 
    music: 
    notes: 󰎚
    photos: 
    podcasts: 
    preview: 
    safari: 󰀹
    wechat: 
    wezterm: 
}

const focused_border_color = 0xff0dcf6f
const default_border_color = 0x88ffffff
const animation_frames = 20

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

    let extra = (if $sid == $focused_sid
        {{
            highlight: on
            border_color: $focused_border_color
        }}
        else {{
            highlight: off
            border_color: $default_border_color
        }})

    ['--set' $"space.($sid)"]
    | append (if (($windows | is-empty) and ($sid != $focused_sid)) {
        [
            background.drawing=off
            label=
            padding_left=-2
            padding_right=-2
        ]
    } else {
        [
            background.drawing=on
            label=($icons)
            label.highlight=($extra.highlight)
            padding_left=2
            padding_right=2
        ]
    })
    | append background.border_color=($extra.border_color)
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
    sketchybar --animate linear $animation_frames ...($batched_args)
}

match $env.SENDER {
    _ => {
        # use listener's label to store last focused space id
        let last_sid = (sketchybar --query $env.NAME | from json | get label.value)
        modify_workspaces $last_sid
    }
}