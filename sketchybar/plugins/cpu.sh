#!/usr/bin/env bash

load=$(top -l 1 | awk '/CPU usage/ { user=$3; sys=$5 } END {
  cpu = sprintf("%.0f", user + sys)
  if (length(cpu) < 2) {
    cpu = "░" cpu
  }
  print cpu
}')

sketchybar --set "$NAME" label="${load}%"
