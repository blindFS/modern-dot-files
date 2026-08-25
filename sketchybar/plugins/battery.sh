#!/usr/bin/env bash

raw_info=$(pmset -g batt)

# Extract percentage using regex matching
if [[ $raw_info =~ ([0-9]+)% ]]; then
  percentage="${BASH_REMATCH[1]}"
else
  percentage=100
fi

# Determine icon based on power source and percentage
if [[ $raw_info == *"AC Power"* ]]; then
  icon=""
else
  if (( percentage > 80 )); then
    icon=""
  elif (( percentage > 60 )); then
    icon=""
  elif (( percentage > 40 )); then
    icon=""
  elif (( percentage > 20 )); then
    icon=""
  else
    icon=""
  fi
fi

# Update sketchybar item
sketchybar --set "$NAME" icon="$icon" label="${percentage}%"
