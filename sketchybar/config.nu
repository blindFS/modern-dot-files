#!/usr/bin/env nu

const colors = {
    fg: 0x88ffffff
    bg: 0x55000000
    white: 0xffffffff
    black: 0xff000000
    transparent: 0x00000000
    yellow: 0xffe0af68
    blue: 0xff7dcfff
    green: 0xff0dcf6f
    orange: 0xfff7768e
    purple: 0xffbb9af7
}

const config = {
    default: {
        align: center
        updates: when_shown
        padding_left: 2
        padding_right: 2
        icon.font: "Sarasa Term SC Nerd:Bold:17.0"
        label.font: "Sarasa Term SC Nerd:Bold:12.0"
        icon.color: $colors.white
        label.color: $colors.fg
        icon.padding_left: 8
        icon.padding_right: 2
        label.padding_left: 2
        label.padding_right: 8
        background.corner_radius: 10
        background.color: $colors.bg
        background.border_width: 1
        background.border_color: $colors.bg
      }

    workspace_default_args: {
        updates: on
        drawing: off
        icon.shadow.drawing: on
        icon.shadow.color: $colors.bg
        icon.shadow.distance: 3
        icon.highlight_color: $colors.green
        background.color: $colors.transparent
        background.border_width: 2
        background.border_color: $colors.fg
        background.shadow.drawing: on
        background.shadow.color: $colors.bg
        background.shadow.distance: 3
    }

    plugin_configs: [
        {
            name: front_app
            pos: left
            events: [front_app_switched aerospace_mode_change]
            args: {
                label.color: $colors.black
                icon.color: $colors.black
                icon.drawing: on
                background.color: $colors.blue
                background.corner_radius: 3
                background.shadow.drawing: on
                background.shadow.color: $colors.bg
                background.shadow.distance: 3
                script: front_app.nu
            }
        }
        {
            name: clock
            args: {
                update_freq: 10
                icon: 
                script: clock.nu
                background.corner_radius: 3
                padding_right: 1
                padding_left: 1
                label.font.size: 10
            }
        }
        {
            name: volume
            events: [volume_change]
            args: {
                script: volume.nu
                background.corner_radius: 3
                padding_right: 1
                padding_left: 1
            }
        }
        {
            name: battery
            events: [system_woke power_source_change]
            args: {
                update_freq: 120
                script: battery.nu
                background.corner_radius: 3
                padding_right: 1
            }
        }
        {
            name: separator_right
            events: [toggle_stats]
            args: {
                icon: 
                padding_left: 0
                label.drawing: off
                background.drawing: off
                click_script: 'sketchybar --trigger toggle_stats'
                script: toggle_stats.nu
            }
        }
        {
            name: disk
            args: {
                icon: 
                update_freq: 120
                script: disk.nu
                icon.color: $colors.green
                background.border_color: $colors.green
            }
        }
        {
            name: cpu
            args: {
                icon: 
                update_freq: 10
                script: cpu.nu
                icon.color: $colors.yellow
                background.border_color: $colors.yellow
            }
        }
        {
            name: memory
            args: {
                icon: ﬙
                update_freq: 10
                script: mem.nu
                icon.color: $colors.blue
                background.border_color: $colors.blue
            }
        }
        {
            name: temp_cpu
            args: {
                icon: 
                label.font.size: 7
                label.y_offset: -4
                icon.font.size: 16
                update_freq: 10
                padding_left: -58
                script: temp.nu
            }
        }
        {
            name: temp_gpu
            args: {
                label.font.size: 7
                padding_left: 0
                padding_right: 0
                icon.font.size: 16
                icon.drawing: off
                label.y_offset: 4
                background.drawing: off
            }
        }
        {
            name: network_down
            args: {
                icon: 󰖩
                label.font.size: 7
                label.y_offset: -4
                update_freq: 3
                padding_left: -69
                padding_right: 23
                script: network.nu
                icon.color: $colors.purple
                label.highlight_color: $colors.purple
                background.border_color: $colors.purple
            }
        }
        {
            name: network_up
            args: {
                label.font.size: 7
                padding_left: 0
                padding_right: 0
                icon.drawing: off
                label.y_offset: 4
                background.drawing: off
                label.highlight_color: $colors.purple
            }
        }
    ]
}

def arg_to_setting [plugin_dir: string] {
    $in
    | transpose
    | each {|row|
        let value = (
            if ($row.column0 == 'script')
                {$plugin_dir | path join $row.column1}
            else {$row.column1})
        $"($row.column0)=($value)"}
}

def build_sketchybar_args [plugin_dir: string] {
    let name = $in | get name
    let pos = $in | get -i pos | default right
    let events = $in | get -i events | default []
    let args = $in | get -i args | default []
    mut arg_list = ['--add' 'item' $name $pos]

    if ($events | is-not-empty) {
        $arg_list = $arg_list
        | append ['--subscribe' $name]
        | append $events
    }

    if ($args | is-not-empty) {
        $arg_list = $arg_list
        | append ['--set' $name]
        | append ($args | arg_to_setting $plugin_dir)
    }
    $arg_list
}