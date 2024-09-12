#!/usr/bin/env nu

const stats = [
	disk
	cpu
	memory
	temp_cpu
	temp_gpu
	network_down
	network_up
]

def toggle_stats [] {
	let state = (sketchybar --query $env.NAME | from json | get icon.value)
	let new_icon = (if $state == "" {""} else "")
	let args = (
		$stats
		| each {|item| [--set $item drawing=toggle]}
		| flatten
	)
	sketchybar ...($args) --set $env.NAME icon=($new_icon)
}

match $env.SENDER {
	"toggle_stats" => { toggle_stats }
}