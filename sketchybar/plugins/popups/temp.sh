#!/usr/bin/env bash

tool_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/iSMC"

args=(--set "$NAME" popup.drawing=toggle)

# Query current popup state
popup_drawing=$(sketchybar --query "$NAME" | jq -r '.popup.drawing // "off"')

if [[ "$popup_drawing" == "off" ]]; then
  fans_info=$("$tool_path" fans -o json)
  power_info=$("$tool_path" power -o json)

  # Extract fan metrics
  fan_curr=$(jq -r '."Fan 1 Current Speed".quantity // 0' <<<"$fans_info")
  fan_max=$(jq -r '."Fan 1 Maximum Speed".quantity // 1' <<<"$fans_info")

  # Calculate fan load percentage with 1 decimal precision
  fan1_load=$(awk -v curr="$fan_curr" -v max="$fan_max" 'BEGIN { if (max > 0) printf "%.1f", (curr / max) * 100; else print "0.0" }')

  # Extract power consumption
  power_consumption=$(jq -r '."System Total".value // "unk"' <<<"$power_info")

  args+=(
    --set temp_fan1 label="${fan1_load} %"
    --set temp_power label="${power_consumption}"
  )
fi

# Execute sketchybar command
sketchybar "${args[@]}"
