#!/usr/bin/env nu

const hidden_offset = 30
const shown_offset = 0 
const animation_args = [--animate sin 30]

let media_info = $env.INFO | from json
let last_song = sketchybar --query media
    | from json | get label.value
let label = $"($media_info
    | get -i title | default '') - ($media_info
    | get -i artist | default '')"
let tmp_cover_image_fp = $env.FILE_PWD | path join cover
let icon_and_offset = match [$media_info.state ($last_song != $label)] {
    ['playing' true] => ['' $hidden_offset]
    ['playing' false] => ['' $shown_offset]
    ['paused' _] => ['' $hidden_offset]
    _ => ['󰐎' $hidden_offset]
}

let args = $animation_args
    | append [
        --set media label=($label) icon=($icon_and_offset.0)
        --set media_cover y_offset=($icon_and_offset.1)]
sketchybar ...$args

if ($last_song != $label) {
    sleep 1sec
    nowplaying-cli get artworkData
    | if $in == 'null' {
        rm $tmp_cover_image_fp
    } else {
        $in
        | base64 --decode
        | save -f $tmp_cover_image_fp
    }
}

if ($media_info.state == 'playing') {
    (sketchybar ...$animation_args
        --set media_cover y_offset=($shown_offset)
        background.image=($tmp_cover_image_fp))
}
