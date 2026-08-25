#!/usr/bin/env bash

# Auto-detect default interface (e.g., en0, llw0), fallback to llw0 if detection fails
INTERFACE=$(route -n get default 2>/dev/null | awk '/interface:/ {print $2}')
INTERFACE="${INTERFACE:-llw0}"

# Read speed metrics for the targeted interface (tail -n 1 extracts the values on line 3)
read -r down_kb up_kb < <(ifstat -i "$INTERFACE" -q 1 1 | tail -n 1)

symbols_up=""
symbols_down=""
fill_char="░"

format_speed() {
  local kb=$1
  local symbol=$2
  local bytes=$(awk -v k="$kb" 'BEGIN { print k * 1024 }')
  local val len pad highlight

  if (($(awk -v k="$kb" 'BEGIN { print (k < 1) }'))); then
    val="$(awk -v b="$bytes" 'BEGIN { printf "%.0f B", b }')"
  elif (($(awk -v k="$kb" 'BEGIN { print (k < 1024) }'))); then
    val="$(awk -v k="$kb" 'BEGIN { printf "%.1f KBps", k }')"
  else
    val="$(awk -v k="$kb" 'BEGIN { printf "%.1f MBps", k / 1024 }')"
  fi

  # Right-align and pad with '░' to width 10
  len=${#val}
  pad=""
  for ((i = 0; i < (10 - len); i++)); do
    pad+="$fill_char"
  done

  # Highlight if throughput exceeds 1 MiB/s (1024 KB/s)
  if (($(awk -v k="$kb" 'BEGIN { print (k >= 1024) }'))); then
    highlight="on"
  else
    highlight="off"
  fi

  REPLY_LABEL="${symbol} ${pad}${val}"
  REPLY_HIGHLIGHT="${highlight}"
}

format_speed "$up_kb" "$symbols_up"
up_label="$REPLY_LABEL"
up_highlight="$REPLY_HIGHLIGHT"

format_speed "$down_kb" "$symbols_down"
down_label="$REPLY_LABEL"
down_highlight="$REPLY_HIGHLIGHT"

sketchybar \
  --set network_up label="$up_label" label.highlight="$up_highlight" \
  --set network_down label="$down_label" label.highlight="$down_highlight"
