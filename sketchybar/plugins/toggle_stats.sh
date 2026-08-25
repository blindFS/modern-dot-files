#!/usr/bin/env bash

stats_plugins=(
  disk
  cpu
  memory
  temp_cpu
  temp_gpu
  network_down
  network_up
)

args=()
for plugin in "${stats_plugins[@]}"; do
  args+=(--set "$plugin" drawing=toggle)
done

# Query the current icon of the triggering item
state=$(sketchybar --query "$NAME" | jq -r '.icon.value // empty')

if [[ "$state" == "" ]]; then
  new_icon=""
else
  new_icon=""
fi

args+=(--set "$NAME" icon="$new_icon")

sketchybar "${args[@]}"
