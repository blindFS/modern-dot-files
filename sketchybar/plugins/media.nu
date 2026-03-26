#!/usr/bin/env nu -n --no-std-lib

# osascript -e $'display notification "($env | get -o INFO | default "unk")"'
const hidden_offset = 30
const shown_offset = 0
const animation_args = [--animate sin 30]
const label_max_length = 30
const max_retry = 5

# let media_info = $env
#   | get -o INFO
#   | default (
#     {
#       title: 'unk'
#       artist: 'unk'
#       state: 'unk'
#     } | to json
#   )
#   | from json
mut media_info = media-control get | from json

# Text
let label = $"($media_info | get title) - ($media_info | get artist)"
  | if ($in | str length) > $label_max_length {
    ($in | str substring -g ..$label_max_length) + '... '
  } else $in

# let icon_and_offset = match $media_info.state {
#   'playing' => ['' $shown_offset]
#   'paused' => ['' $hidden_offset]
#   _ => ['󰐎' $hidden_offset]
# }
let icon_and_offset = if $media_info.playing {
  ['' $shown_offset]
} else {
  ['' $hidden_offset]
}

let args = $animation_args
  | append [
    --set
    media
    label=($label)
    icon=($icon_and_offset.0)
    --set
    media_cover
    y_offset=($hidden_offset)
  ]

sketchybar ...$args

# Artwork
mut retry_count = 0
# In case the network is poor
while ($media_info.artworkMimeType? | is-empty) and ($retry_count < $max_retry) {
  sleep 1sec
  $media_info = ^media-control get | from json
  $retry_count += 1
}

let artwork_mime = $media_info | get artworkMimeType | split words | last
let cover_cache_path = $'($env.HOME)/.cache/cover.($artwork_mime)'
$media_info | get artworkData | base64 --decode | save -f $cover_cache_path

let args = $animation_args
  | append [
    --set
    media_cover
    background.image=($cover_cache_path)
    y_offset=($icon_and_offset.1)
  ]

sketchybar ...$args
