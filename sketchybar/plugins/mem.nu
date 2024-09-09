#!/usr/bin/env nu

let free = memory_pressure | lines | last | split row ":" | last | parse " {num}%" | get 0.num | into int
sketchybar --set $env.NAME label=$'(100 - $free)%'