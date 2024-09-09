#!/usr/bin/env nu

let stats = [
	"cpu.percent"
	"memory"
	"temp.cpu"
	"temp.gpu"
	"net.down"
	"net.up"
]

def toggle_stats [] {
	let state = (sketchybar --query separator_right | from json | get icon.value)
	let new_icon = (if $state == "" {""} else "")
	let draw = (if $state == "" {"off"} else "on")
	let args = (
		$stats
		| each {|item| ["--set" $item $"drawing=($draw)"]}
		| flatten
	)
	sketchybar ...($args) --set separator_right icon=$"($new_icon)"
}

match $env.SENDER {
	"toggle_stats" => { toggle_stats }
}