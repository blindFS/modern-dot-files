#!/usr/bin/env bash

total_bytes=$(sysctl -n hw.memsize)
page_size=$(sysctl -n hw.pagesize)

# Calculate used memory percentage using vm_stat and sysctl
used_percentage=$(vm_stat | awk -v total="$total_bytes" -v ps="$page_size" '
  /Pages free:/ { free = $3 }
  /Pages speculative:/ { spec = $3 }
  /Pages inactive:/ { inact = $3 }
  END {
    gsub(/[^0-9]/, "", free)
    gsub(/[^0-9]/, "", spec)
    gsub(/[^0-9]/, "", inact)
    avail_bytes = (free + spec + inact) * ps
    used_bytes = total - avail_bytes
    printf "%.0f", (used_bytes / total) * 100
  }
')

sketchybar --set "$NAME" label="${used_percentage}%"
