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
    'system settings': 󰒓
}

let icon = ($app_icons | get -i ($env.INFO | str downcase) | default '')

if ($env.SENDER == "front_app_switched") {
    sketchybar --set $env.NAME label=($env.INFO) icon=($icon)
}