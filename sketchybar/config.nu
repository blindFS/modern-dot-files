#!/usr/bin/env nu

export def arg_to_setting [plugin_dir: string] record -> list<string> {
    $in
    | transpose name value
    | each { |pair|
        $pair
        | update 'value' { 
            if ($pair.name | str ends-with 'script') {$pair.value
                | str replace '{}' $plugin_dir} else $pair.value}
        | $"($in.name)=($in.value)" }
}

def build_sketchybar_args [plugin_dir: string] record -> list<string> {
    let name = $in | get -i name | default temp_name
    let pos = $in | get -i pos | default right
    let events = $in | get -i events | default []
    let args = $in | get -i args | default []
    let popups = $in | get -i popups | default []
    mut arg_list = [--add item $name $pos]

    if ($events | is-not-empty) {
        $arg_list = $arg_list
        | append [--subscribe $name]
        | append $events
    }

    if ($args | is-not-empty) {
        $arg_list = $arg_list
        | append [--set $name]
        | append ($args | arg_to_setting $plugin_dir)
    }

    if ($popups | is-not-empty) {
        $arg_list = $arg_list
        | append ($popups
            | each {|p_it|
                mut p_it_cml_args = [--add item $p_it.name popup.($name)]
                let p_it_args = $p_it | get -i args | default []
                if ($p_it_args | is-not-empty) {
                    $p_it_cml_args = $p_it_cml_args
                    | append [--set $p_it.name]
                    | append ($p_it_args | arg_to_setting $plugin_dir)
                }
                $p_it_cml_args
            }
            | flatten
        )
    }
    $arg_list
}

def args_per_workspace [
    id: string
    ws_config: record
    plugin_dir: string
] nothing -> list<string> {
  ['--add' 'item' $"space.($id)" 'left']
  | append ['--set' $"space.($id)" $"icon=($id)" $"click_script=aerospace workspace ($id)"]
  | append ($ws_config | arg_to_setting $plugin_dir)
}

export def workspace_args [
    ws_config: record
    plugin_dir: string
] nothing -> list<string> {
    aerospace list-workspaces --all
    | lines
    | each { args_per_workspace $in $ws_config $plugin_dir }
    | flatten
}

export def build_all_plugin_args [
    plugin_dir: string
] record -> list<string> {
    $in
    | each { $in | build_sketchybar_args $plugin_dir}
    | flatten
}