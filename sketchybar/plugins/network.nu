#!/usr/bin/env nu
const symbols = {
    up: 
    down: 
    fill: ░
}

let start_info = sys net | select sent recv | math sum
sleep 1sec
let end_info = sys net | select sent recv | math sum

let new_args = [$start_info $end_info]
    | rename up down
    | transpose key start end
    | each {|r| 
        let bps = $r.end - $r.start
        [
            --set
            network_($r.key)
            $"label=($symbols | get $r.key) ($bps
                | into string
                | str replace 'iB' 'Bps'
                | fill -a r -c $symbols.fill -w 10)"
            label.highlight=(if $bps > 1Mib {'on'} else 'off')
        ]
    }
    | flatten

sketchybar ...($new_args)