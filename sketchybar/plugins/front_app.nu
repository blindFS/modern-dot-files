#!/usr/bin/env nu

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

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

const mode_colors = {
    main: '0xdd7aa2f7'
    operation: '0xfff7768e'
    resize: '0xff0dcf6f'
    service: '0xff000000'
}

match $env.SENDER {
    "front_app_switched" => {
        let icon = ($app_icons | get -i ($env.INFO | str downcase) | default '')
        sketchybar --set $env.NAME label=($env.INFO) icon=($icon)
    }
    "aerospace_mode_change" => {
        let color = ($mode_colors | get -i ($env.MODE | str downcase) | default $mode_colors.main)
        sketchybar --set $env.NAME background.color=($color)
        # change borders color if it is running
        if (ps | where name == 'borders' | is-not-empty) {
            borders active_color=($color)
        }
    }
}