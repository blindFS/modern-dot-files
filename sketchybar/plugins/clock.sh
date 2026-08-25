#!/usr/bin/env bash

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

msg=$(date '+%a %m-%d %H:%M')
sketchybar --set "$NAME" label="$msg"
