#!/usr/bin/env nu
const stats_plugins = [
    disk
    cpu
    memory
    temp_cpu
    temp_gpu
    network_down
    network_up
]

export def toggle_stats_args [] nothing -> list<string> {
    $stats_plugins
    | each { [--set $in drawing=toggle] }
    | flatten
}

let state = (sketchybar --query $env.NAME | from json | get icon.value)
let new_icon = (if $state == "" {""} else "")
sketchybar ...(toggle_stats_args) --set $env.NAME icon=($new_icon)