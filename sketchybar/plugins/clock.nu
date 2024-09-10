#!/usr/bin/env nu

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

let msg = date now | format date "%a %m-%d %H:%M:%S"
sketchybar --set $env.NAME label=($msg)

