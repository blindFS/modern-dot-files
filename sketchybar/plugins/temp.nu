#!/usr/bin/env nu
use constants.nu colors
let temp_info = sys temp
let cpu_temp = $temp_info | find 'cpu' | get temp | math max
let gpu_temp = $temp_info | find 'gpu' | get temp | math max
let info = (
  match ([$cpu_temp $gpu_temp] | math max) {
    $t if $t > 80 => { icon: "" color: $colors.orange }
    $t if $t > 60 => { icon: "" color: $colors.yellow }
    $t if $t > 40 => { icon: "" color: $colors.green }
    _ => { icon: "" color: $colors.blue }
  }
)
| default ($cpu_temp | into string --decimals 0) 'cpu_temp'
| default ($gpu_temp | into string --decimals 0) 'gpu_temp'
(
  sketchybar
  --set temp_cpu label=$"CPU ($info.cpu_temp) ℃"
  icon=($info.icon) icon.color=($info.color) background.border_color=($info.color)
  --set temp_gpu label=$"GPU ($info.gpu_temp) ℃"
)
