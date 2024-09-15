#!/usr/bin/env nu

use constants.nu [app_icons colors]
use helper.nu workspace_modification_args

const animate_frames = 30
# remained for other possible signals
match $env.SENDER {
    _ => {
        # invisible item to store last focused sid
        let last_sid = (sketchybar --query $env.NAME | from json | get label.value)
        sketchybar --animate tanh $animate_frames ...(workspace_modification_args $env.NAME $last_sid)
    }
}