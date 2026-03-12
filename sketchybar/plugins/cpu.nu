#!/usr/bin/env nu -n --no-std-lib

let load = (
  sys cpu -l
  | get cpu_usage | math avg
  | into string --decimals 0
  | fill -a r -c '░' -w 2
)
sketchybar --set $env.NAME label=($load)%
