#!/usr/bin/env bash

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

if [[ "$SENDER" == "volume_change" ]]; then
  volume="${INFO%.*}"

  if (( volume > 60 )); then
    icon="󰕾"
  elif (( volume > 30 )); then
    icon="󰖀"
  elif (( volume > 0 )); then
    icon="󰕿"
  else
    icon="󰖁"
  fi

  sketchybar --set "$NAME" icon="$icon" label="$INFO"
fi
