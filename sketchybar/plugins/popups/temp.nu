#!/usr/bin/env nu

let args = [--set $env.NAME popup.drawing=toggle]
| append (
  if (sketchybar --query $env.NAME | from json | get popup.drawing) == 'off' {
    let tool_path = ($env.FILE_PWD) | path join 'iSMC'
    let fans_info = ^$tool_path fans -o json | from json
    let power_info = ^$tool_path power -o json | from json
    let fan1_load = ($fans_info.'Fan 1 Current Speed'.quantity / $fans_info.'Fan 1 Maximum Speed'.quantity * 100) | into string --decimals 1
    let fan2_load = ($fans_info.'Fan 2 Current Speed'.quantity / $fans_info.'Fan 2 Maximum Speed'.quantity * 100) | into string --decimals 1
    let power_consumption = $power_info.'System Total'.value
    [
      --set
      temp_fan1
      $'label=($fan1_load) %'
      --set
      temp_fan2
      $'label=($fan2_load) %'
      --set
      temp_power
      label=($power_consumption)
    ]
  } else []
)
sketchybar ...$args
