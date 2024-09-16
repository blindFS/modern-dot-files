use constants.nu [app_icons colors]
const stats_plugins = [
    disk
    cpu
    memory
    temp_cpu
    temp_gpu
    network_down
    network_up
]

export def get_cpu_load [] nothing -> string {
    sys cpu
    | get cpu_usage | math avg
    | into string --decimals 0
    | fill -a r -c '░' -w 2
}

export def get_mem_free_percentage [] nothing -> string {
    sys mem
    | ($in.available / $in.total) * 100
    | into string --decimals 0
}

export def get_disk_free_percentage [] nothing -> string {
    sys disks
    | where mount == '/' | first
    | ($in.free) / ($in.total) * 100
    | into string --decimals 0
}

export def get_temperature_info [] nothing -> record {
    let temp_info = sys temp
    let cpu_temp = $temp_info | find 'cpu' | get temp | math max
    let gpu_temp = $temp_info | find 'gpu' | get temp | math max

    match ([$cpu_temp $gpu_temp] | math max) {
        $t if $t > 80 => {icon: "", color: $colors.orange}
        $t if $t > 60 => {icon: "", color: $colors.yellow}
        $t if $t > 40 => {icon: "", color: $colors.green}
        _ => {icon: "", color: $colors.blue}
    }
    | default ($cpu_temp | into string --decimals 0) 'cpu_temp'
    | default ($gpu_temp | into string --decimals 0) 'gpu_temp'
}

export def get_icon_by_app_name [] string -> string {
    let name = $in | str downcase
    $app_icons
    | get -i $name
    | default ''
}

export def network_info_update_args [] nothing -> record {
    const symbols = {
        up: 
        down: 
        fill: ░
    }

    let start_info = sys net | select sent recv | math sum
    sleep 1sec
    let end_info = sys net | select sent recv | math sum

    [$start_info $end_info]
    | rename up down
    | transpose key start end
    | each { |r| 
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
}

def modify_args_per_workspace [
    sid: string
    focused_sid: string
] nothing -> list<string> {
    let icons = (aerospace list-windows --workspace $sid
        | lines
        | par-each { $in
            | split row '|' | get 1
            | str trim | str downcase
            | get_icon_by_app_name
        }
        | uniq | str join ' ')
    let extra = (if $sid == $focused_sid
        {
            { highlight: on border_color: $colors.green }
        } else {
            { highlight: off border_color: $colors.fg }
        })

    ['--set' $"space.($sid)"]
    | append (if (($icons | is-empty) and ($sid != $focused_sid)) {
        [
            background.drawing=off
            label=
            padding_left=-2
            padding_right=-2
        ]
    } else {
        [
            background.drawing=on
            label=($icons)
            label.highlight=($extra.highlight)
            padding_left=2
            padding_right=2
        ]
    })
    | append background.border_color=($extra.border_color)
}

export def workspace_modification_args [
    name: string
    last_sid: string
] nothing -> list<string> {
    # use listener's label to store last focused space id
    let focused_sid = (aerospace list-workspaces --focused)
    let ids_to_modify = (
        if ($last_sid | is-empty)
            {(aerospace list-workspaces --all | lines)}
        else {
            [$focused_sid $last_sid]
        })
    $ids_to_modify
    | uniq
    | each { modify_args_per_workspace $in $focused_sid }
    | flatten
    | append ["--set" $name $"label=($focused_sid)"]
}

export def toggle_stats_args [] nothing -> list<string> {
    $stats_plugins
    | each { [--set $in drawing=toggle] }
    | flatten
}