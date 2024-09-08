# Nushell Environment Config File
#
# version = "0.97.1"

source style.nu

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# Directories to search for scripts when calling source or use
# The default for this is $nu.default-config-dir/scripts
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
    ($nu.data-dir | path join 'completions') # default home for nushell completions
]

# Directories to search for plugin binaries when calling register
# The default for this is $nu.default-config-dir/plugins
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

$env.LS_COLORS = (vivid generate tokyonight-night | str trim)

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')
# An alternate way to add entries to $env.PATH is to use the custom command `path add`
# which is built into the nushell stdlib:
# use std "path add"
# $env.PATH = ($env.PATH | split row (char esep))
# path add /some/path
# path add ($env.CARGO_HOME | path join "bin")
# path add ($env.HOME | path join ".local" "bin")
# $env.PATH = ($env.PATH | uniq)

use std "path add"
path add ($env.HOME | path join ".elan" "bin")
path add ($env.HOME | path join ".local" "bin")

# To load from a custom file you can use:
# starship init nu | save -f ($nu.default-config-dir | path join 'starship.nu')
zoxide init nushell | save -f ($nu.default-config-dir | path join 'zoxide.nu')

$env.FZF_DEFAULT_COMMAND = "fd --hidden --strip-cwd-prefix --exclude .git --exclude .cache --max-depth 9"
$env.FZF_DEFAULT_OPTS = ("--layout=reverse --tmux=center,60%,50% " +
    "--color=fg:#9aaaaa,hl:#f7768e " +
    "--color=fg+:#c0caf5,bg+:#1a1b26,hl+:#f7768e " +
    "--color=info:#7aa2f7,prompt:#e0af68,pointer:#f7768e " +
    "--color=marker:#a9b1d6,spinner:#9ece6a,header:#a9b1d6")

$env.CARAPACE_LENIENT = 1
$env.CARAPACE_BRIDGES = 'zsh,bash'