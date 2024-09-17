#!/usr/bin/env nu

let free_percentage = (
    sys mem
    | ($in.available / $in.total) * 100
    | into string --decimals 0
)
sketchybar --set $env.NAME label=($free_percentage)%