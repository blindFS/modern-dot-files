#!/usr/bin/env nu

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

use constants.nu mode_colors
use helper.nu get_icon_by_app_name

match $env.SENDER {
    "front_app_switched" => {
        sketchybar --set $env.NAME label=($env.INFO) icon=($env.INFO | get_icon_by_app_name)
    }
    "aerospace_mode_change" => {
        let color = ($mode_colors | get -i $env.MODE | default $mode_colors.main)

        sketchybar --animate linear 30 --set $env.NAME background.color=($color)
        # change borders color if it is running
        if (ps | where name == 'borders' | is-not-empty) {
            borders active_color=($color)
        }
    }
}