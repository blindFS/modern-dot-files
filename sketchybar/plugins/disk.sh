#!/usr/bin/env bash

# Uses df -Pk to get root filesystem stats in standard POSIX 1024-byte blocks
free_percentage=$(df -Pk / | awk 'NR==2 { printf "%.0f", ($4 / $2) * 100 }')

sketchybar --set "$NAME" label="${free_percentage}%"
