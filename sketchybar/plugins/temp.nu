#!/usr/bin/env nu
use constants.nu colors
let tool_path = ($env.FILE_PWD) | path join popups iSMC

def extract_by_key [
  key: string
] {
  $in
  | where key =~ $key
  | par-each {|kv| $kv.value}
  | where quantity != 40
  | get -i quantity
  | default [40]
  | math max
}

let temp_info = ^$tool_path temp -o json
| from json | transpose key value
let cpu_temp = $temp_info | extract_by_key '^CPU'
let gpu_temp = $temp_info | extract_by_key '^GPU'
let info = (
  match ([$cpu_temp $gpu_temp] | math max) {
    $t if $t > 80 => { icon: "" color: $colors.orange }
    $t if $t > 60 => { icon: "" color: $colors.yellow }
    $t if $t > 40 => { icon: "" color: $colors.green }
    _ => { icon: "" color: $colors.blue }
  }
)
| default (
  $cpu_temp
  | into string --decimals 0
  | fill -a r -c '░' -w 2
) 'cpu_temp'
| default (
  $gpu_temp
  | into string --decimals 0
  | fill -a r -c '░' -w 2
) 'gpu_temp'
(
  sketchybar
  --set temp_cpu $"label=CPU ($info.cpu_temp) ℃"
  icon=($info.icon) icon.color=($info.color) background.border_color=($info.color)
  --set temp_gpu $"label=GPU ($info.gpu_temp) ℃"
)
