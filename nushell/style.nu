def prompt_decorator [font_color: string, bg_color: string, symbol: string] {
    let fg = {fg: $bg_color}
    let bg = {fg: $font_color, bg: $bg_color}
    $"(ansi --escape $fg)(ansi --escape $bg)($symbol)(ansi reset)(ansi --escape $fg)(ansi reset) "
}

$env.PROMPT_INDICATOR = {|| "> " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| (prompt_decorator "#111726" "#78BF75" "󰏫") }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| (prompt_decorator "#111726" "#E0AF68" "") }
$env.PROMPT_MULTILINE_INDICATOR = {|| "-> " }