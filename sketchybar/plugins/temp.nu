#!/usr/bin/env nu

let temp_info = sys temp
let cpu_temp = $temp_info | find 'cpu' | get temp | math max
let gpu_temp = $temp_info | find 'gpu' | get temp | math max

let deg = match ([$cpu_temp $gpu_temp] | math max) {
    $t if $t > 80 => {icon: "", color: "0xfff7768e"}
    $t if $t > 60 => {icon: "", color: "0xffe0af68"}
    $t if $t > 40 => {icon: "", color: "0xff0dcf6f"}
    _ => {icon: "", color: "0xff7dcfff"}
}

(sketchybar
    --set temp_cpu label=$"CPU ($cpu_temp | into string --decimals 0) ℃"
        icon=($deg.icon) icon.color=($deg.color) background.border_color=($deg.color)
    --set temp_gpu label=$"GPU ($gpu_temp | into string --decimals 0) ℃"
)