#!/usr/bin/env nu

let cpu_temp = smctemp -c | into float
let gpu_temp = smctemp -g | into float

let msg = $"($gpu_temp | into string --decimals 0)  ($cpu_temp | into string --decimals 0)"

let deg = match ([$cpu_temp $gpu_temp] | math max) {
    $t if $t > 80 => {icon: "", color: "0xfff7768e"}
    $t if $t > 60 => {icon: "", color: "0xffe0af68"}
    $t if $t > 40 => {icon: "", color: "0xff0dcf6f"}
    _ => {icon: "", color: "0xff7dcfff"}
}

sketchybar --animate sin 60 --set temp.cpu label=$"CPU ($cpu_temp | into string --decimals 0) ℃" icon=$"($deg.icon)" icon.color=$"($deg.color)" background.border_color=$"($deg.color)"
sketchybar --set temp.gpu label=$"GPU ($gpu_temp | into string --decimals 0) ℃"