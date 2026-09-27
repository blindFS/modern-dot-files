#!/usr/bin/env bash

# Source dependencies relative to this script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/constants.sh"
source "$SCRIPT_DIR/style.sh"

case "$SENDER" in
"front_app_switched")
  icon=$(get_icon_by_app_name "$INFO")
  sketchybar --set "$NAME" label="$INFO" icon="$icon"
  ;;

"wm_mode_change")
  # Resolve background color based on current AeroSpace mode
  case "$MODE" in
  "main") color="${COLOR_BLUE}" ;;
  "operation") color="${COLOR_ORANGE}" ;;
  "resize") color="${COLOR_GREEN}" ;;
  "service") color="${COLOR_WHITE}" ;;
  *) color="${COLOR_BLUE}" ;;
  esac

  sketchybar --animate linear 30 --set "$NAME" background.color="$color"

  # Update active border color if JankBorders (borders) is running
  if pgrep -x "borders" >/dev/null 2>&1; then
    borders active_color="$color"
  fi
  ;;
esac
