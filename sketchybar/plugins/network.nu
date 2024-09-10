#!/usr/bin/env nu

def format_bps [bps: string, width: int] {
    let bps = ($bps + 'kib') | into filesize
    {
        msg: ($bps | into string | fill -a r -c '░' -w $width),
        highlight: (if $bps > 1Mib {"on"} else {"off"})
    }
}

let table = ifstat -i "en0" -b 0.1 1 | lines | last | parse --regex '\s*(?<down>[0-9.]+)\s*(?<up>[0-9.]+)' | get 0
let up_d = format_bps $table.up 9
let down_d = format_bps $table.down 9

sketchybar --animate tanh 30 --set network_down label=$" ($down_d.msg)" label.highlight=($down_d.highlight)
sketchybar --animate tanh 30 --set network_up label=$" ($up_d.msg)" label.highlight=($up_d.highlight)