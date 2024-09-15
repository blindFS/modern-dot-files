#!/usr/bin/env nu
use helper.nu get_disk_free_percentage

sketchybar --set $env.NAME label=(get_disk_free_percentage)%