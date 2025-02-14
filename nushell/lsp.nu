# Minimal config file for LSP
$env.PATH = $env.PATH
| split row (char esep)
| append '/usr/local/bin'
| append ($env.HOME | path join ".cargo" "bin")
| uniq

$env.CARAPACE_LENIENT = 1
$env.CARAPACE_BRIDGES = 'zsh'
$env.config.completions.external.completer = {|spans: list<string>|
  carapace $spans.0 nushell ...$spans
  | from json
  | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
}
