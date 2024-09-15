#!/usr/bin/env nu

use helper.nu toggle_stats_args

let state = (sketchybar --query $env.NAME | from json | get icon.value)
let new_icon = (if $state == "" {""} else "")
sketchybar ...(toggle_stats_args) --set $env.NAME icon=($new_icon)