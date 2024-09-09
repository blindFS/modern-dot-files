#!/usr/bin/env nu

let load = ps | get cpu | math sum | into string --decimals 0
let msg = $load | fill -a r -c '░' -w 3

sketchybar --set $env.NAME label=$"($msg)%"
