#!/usr/bin/env nu
use helper.nu get_cpu_load

sketchybar --set $env.NAME label=(get_cpu_load)%
