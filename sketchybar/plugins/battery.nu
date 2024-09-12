#!/usr/bin/env nu

let raw_info = (pmset -g batt)
let percentage = ($raw_info
  | parse --regex '.*\s(\d+)%; .*'
  | get -i 0.capture0
  | default 100
  | into float)

let icon = (if ($raw_info | str contains 'AC Power')
    {''}
  else {
    match $percentage {
      $p if $p > 80 => ''
      $p if $p > 60 => ''
      $p if $p > 40 => ''
      $p if $p > 20 => ''
      _ => ''
    }
  })

# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
sketchybar --set $env.NAME icon=($icon) label=($percentage)%
