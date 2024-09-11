#!/usr/bin/env nu

let free_percentage = sys disks
    | where mount == '/'
    | first
    | do {|| ($in.free) / ($in.total) * 100
        | into string --decimals 0}

sketchybar --set $env.NAME label=($free_percentage)%