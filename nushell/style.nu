def prompt_decorator [
    font_color: string
    bg_color: string
    symbol: string
    with_starship?: bool = true
] {
    let bg1 = if $with_starship {'#A3AED2'} else $bg_color
    let fg = {fg: $bg_color}
    let bg = {fg: $font_color, bg: $bg_color}
    let startship_leading = if $with_starship {$"(ansi --escape {fg: $bg_color, bg: $bg1})"} else ''
    $"($startship_leading)(ansi --escape $bg)($symbol)(ansi reset)(ansi --escape $fg)(ansi reset) "
}

$env.PROMPT_INDICATOR = {|| "> " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| prompt_decorator "#111726" "#0DCF6F" "󰏫" }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| prompt_decorator "#111726" "#E0AF68" "" }
# $env.PROMPT_MULTILINE_INDICATOR = {|| "-> " }

# If you want previously entered commands to have a different prompt from the usual one,
# you can uncomment one or more of the following lines.
# This can be useful if you have a 2-line prompt and it's taking up a lot of space
# because every command entered takes up 2 lines instead of 1. You can then uncomment
# the line below so that previously entered commands show with a single `🚀`.
# $env.TRANSIENT_PROMPT_COMMAND = {|| "🚀" }
# $env.TRANSIENT_PROMPT_COMMAND = {|| (do $env.PROMPT_COMMAND | split row "\n" | take 2) }
# $env.TRANSIENT_PROMPT_INDICATOR = {|| "" }
# $env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = {|| "" }
# $env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = {|| "" }
# $env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = {|| "" }