#!/usr/bin/env nu

let table = df -h | jc --df | from json | where mounted_on == '/System/Volumes/Data'

sketchybar --set $env.NAME label=$"($table | get 0.capacity_percent)%"