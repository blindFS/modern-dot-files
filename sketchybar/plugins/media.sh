#!/usr/bin/env bash

hidden_offset=30
shown_offset=0
animation_args=(--animate sin 30)
label_max_length=30
max_retry=5

media_info=$(media-control get)

if [[ -z "$media_info" ]]; then
  exit 0
fi

# Parse media details
title=$(jq -r '.title // "__"' <<<"$media_info")
artist=$(jq -r '.artist // "__"' <<<"$media_info")
playing=$(jq -r '.playing // false' <<<"$media_info")

# Format label text and truncate if necessary
label="$title - $artist"
if ((${#label} > label_max_length)); then
  label="${label:0:label_max_length}... "
fi

# Determine icon and offset based on playback status
if [[ "$playing" == "true" ]]; then
  icon=""
  offset=$shown_offset
else
  icon=""
  offset=$hidden_offset
fi

# First sketchybar update
sketchybar "${animation_args[@]}" \
  --set media label="$label" icon="$icon" \
  --set media_cover y_offset="$hidden_offset"

# Artwork retry loop in case network response is delayed
retry_count=0
artwork_mime=$(jq -r '.artworkMimeType // empty' <<<"$media_info")

while [[ -z "$artwork_mime" ]] && ((retry_count < max_retry)); do
  sleep 1
  media_info=$(media-control get)
  artwork_mime=$(jq -r '.artworkMimeType // empty' <<<"$media_info")
  ((retry_count++))
done

# Extract artwork extension and decode image cache
if [[ -n "$artwork_mime" ]]; then
  # Strip everything up to the slash to get extension (e.g. "jpeg" from "image/jpeg")
  mime_suffix="${artwork_mime##*/}"
  mkdir -p "$HOME/.cache"
  cover_cache_path="$HOME/.cache/cover.$mime_suffix"

  artwork_data=$(jq -r '.artworkData // empty' <<<"$media_info")
  if [[ -n "$artwork_data" ]]; then
    echo "$artwork_data" | base64 --decode >"$cover_cache_path"

    # Second sketchybar update with new cover
    sketchybar "${animation_args[@]}" \
      --set media_cover background.image="$cover_cache_path" y_offset="$offset"
  fi
fi
