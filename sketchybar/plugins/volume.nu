#!/usr/bin/env nu

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

if ($env.SENDER == "volume_change") {
  let icon = (
    match ($env.INFO | into float) {
      $v if $v > 60 => "󰕾",
      $v if $v > 30 => "󰖀",
      $v if $v > 0 => "󰕿",
      _ => "󰖁"
    }
  )
  sketchybar --set $env.NAME icon=($icon) label=($env.INFO)
}
