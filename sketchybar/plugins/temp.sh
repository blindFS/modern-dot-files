#!/usr/bin/env bash

# Source dependencies relative to this script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/style.sh"

tool_path="$SCRIPT_DIR/popups/iSMC"

# Fetch temperature info in JSON format
temp_json=$("$tool_path" temp -o json 2>/dev/null)
temp_json="${temp_json:-{}}"

# Simple jq query: filter keys, collect into an array [...], then pass to max
read -r cpu_temp gpu_temp < <(jq -r '
  [
    ([to_entries[] | select(.key | startswith("CPU")) | .value.quantity | select(. != 40)] | max // 40),
    ([to_entries[] | select(.key | startswith("GPU")) | .value.quantity | select(. != 40)] | max // 40)
  ] | join(" ")
' <<<"$temp_json")

# Format rounded temperature values with padding ('░') if single-digit
format_temp() {
  local rounded
  rounded=$(awk -v t="$1" 'BEGIN { printf "%.0f", t }')
  if ((${#rounded} < 2)); then
    echo "░$rounded"
  else
    echo "$rounded"
  fi
}

cpu_formatted=$(format_temp "$cpu_temp")
gpu_formatted=$(format_temp "$gpu_temp")

# Find max temperature between CPU and GPU
max_temp=$(awk -v c="$cpu_temp" -v g="$gpu_temp" 'BEGIN { print (c > g ? c : g) }')

# Determine status icon and accent color based on max temperature
if (($(awk -v t="$max_temp" 'BEGIN { print (t > 80) }'))); then
  icon=""
  color="${COLOR_ORANGE:-0xfff7768e}"
elif (($(awk -v t="$max_temp" 'BEGIN { print (t > 60) }'))); then
  icon=""
  color="${COLOR_YELLOW:-0xffe0af68}"
elif (($(awk -v t="$max_temp" 'BEGIN { print (t > 40) }'))); then
  icon=""
  color="${COLOR_GREEN:-0xff0dcf6f}"
else
  icon=""
  color="${COLOR_BLUE:-0xdd769ff0}"
fi

# Update sketchybar items
sketchybar \
  --set temp_cpu label="CPU ${cpu_formatted} ℃" icon="$icon" icon.color="$color" background.border_color="$color" \
  --set temp_gpu label="GPU ${gpu_formatted} ℃"
