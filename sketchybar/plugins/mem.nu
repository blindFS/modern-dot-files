#!/usr/bin/env nu
use helper.nu get_mem_free_percentage

sketchybar --set $env.NAME label=(get_mem_free_percentage)%