#!/usr/bin/env nu

let load = (sys cpu
    | get cpu_usage | math avg
    | into string --decimals 0
    | fill -a r -c '░' -w 2)
sketchybar --set $env.NAME label=($load)%
