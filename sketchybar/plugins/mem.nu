#!/usr/bin/env nu -n --no-std-lib

let free_percentage = (
  sys mem
  | ($in.used / $in.total) * 100
  | into string --decimals 0
)
sketchybar --set $env.NAME label=($free_percentage)%
