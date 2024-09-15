#!/usr/bin/env nu
use helper.nu get_temperature_info

let info = get_temperature_info
(sketchybar
    --set temp_cpu label=$"CPU ($info.cpu_temp) ℃"
        icon=($info.icon) icon.color=($info.color) background.border_color=($info.color)
    --set temp_gpu label=$"GPU ($info.gpu_temp) ℃"
)