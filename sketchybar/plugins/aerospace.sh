#!/usr/bin/env bash

# Source dependencies relative to this script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/constants.sh"
source "$SCRIPT_DIR/style.sh"

ANIMATE_FRAMES=30

# Retrieve last focused space ID stored in this item's label
last_sid=$(sketchybar --query "$NAME" | jq -r '.label.value // empty')
focused_sid=$(aerospace list-workspaces --focused 2>/dev/null)

if [[ -z "$focused_sid" ]]; then
  exit 0
fi

# Determine which workspaces to update
if [[ -z "$last_sid" ]]; then
  mapfile -t ids_to_modify < <(aerospace list-workspaces --all)
else
  ids_to_modify=("$focused_sid" "$last_sid")
fi

# Remove duplicate workspace IDs
readarray -t unique_ids < <(printf '%s\n' "${ids_to_modify[@]}" | sort -u)

args=()

for sid in "${unique_ids[@]}"; do
  [[ -z "$sid" ]] && continue

  # Fetch open windows in workspace and convert app names to icons
  windows_json=$(aerospace list-windows --workspace "$sid" --json 2>/dev/null)

  icons=""
  if [[ -n "$windows_json" && "$windows_json" != "[]" ]]; then
    raw_icons=()
    while IFS= read -r app_name; do
      if [[ -n "$app_name" ]]; then
        icon=$(get_icon_by_app_name "$app_name")
        raw_icons+=("$icon")
      fi
    done < <(jq -r '.[]."app-name" // empty' <<<"$windows_json")

    if ((${#raw_icons[@]} > 0)); then
      icons=$(printf '%s\n' "${raw_icons[@]}" | sort -u | paste -sd ' ' -)
    fi
  fi

  # Set active vs inactive workspace styles
  if [[ "$sid" == "$focused_sid" ]]; then
    highlight="on"
    border_color="$COLOR_GREEN"
  else
    highlight="off"
    border_color="$COLOR_FG"
  fi

  # Build sketchybar update flags
  if [[ -z "$icons" && "$sid" != "$focused_sid" ]]; then
    args+=(
      --set "space.$sid"
      background.drawing=off
      label=""
      padding_left=-2
      padding_right=-2
      background.border_color="$border_color"
    )
  else
    args+=(
      --set "space.$sid"
      background.drawing=on
      label="$icons"
      label.highlight="$highlight"
      padding_left=2
      padding_right=2
      background.border_color="$border_color"
    )
  fi
done

# Store current focused workspace ID in the listener item's label
args+=(--set "$NAME" label="$focused_sid")

sketchybar --animate tanh "$ANIMATE_FRAMES" "${args[@]}"
