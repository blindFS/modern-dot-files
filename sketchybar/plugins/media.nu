#!/usr/bin/env nu

# osascript -e $'display notification "($env | get -o INFO | default "unk")"'
const hidden_offset = 30
const shown_offset = 0
const animation_args = [--animate sin 30]
const label_max_length = 30
let media_info = $env
| get -o INFO
| default (
  {
    title: 'unk'
    artist: 'unk'
    state: 'unk'
  } | to json
)
| from json
let label = $"(
  $media_info
  | get -o title | default ''
) - (
  $media_info
  | get -o artist | default ''
)"
| if ($in | str length) > $label_max_length {
  ($in | str substring -g ..$label_max_length) + '... '
} else $in
let icon_and_offset = match $media_info.state {
  'playing' => ['' $shown_offset]
  'paused' => ['' $hidden_offset]
  _ => ['󰐎' $hidden_offset]
}
let args = $animation_args
| append [
  --set
  media
  label=($label)
  icon=($icon_and_offset.0)
  --set
  media_cover
  y_offset=($icon_and_offset.1)
]
sketchybar ...$args
