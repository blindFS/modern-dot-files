# list all installed packages
def nix-list-system []: nothing -> list<string> {
  ^nix-store -q --references /run/current-system/sw
  | lines
  | filter {|| not ($in | str ends-with 'man')}
  | each {|| $in | str replace -r '^[^-]*-' ''}
  | sort
}

# upgrade system packages
def nix-upgrade [flake_path: string]: nothing -> nothing {
  let working_path = $flake_path | path expand
  if not ($working_path | path exists) {
    echo "path not exists: $working_path"
    exit 1
  }
  let pwd = pwd
  cd $working_path
  nix flake update
  cd $pwd
  darwin-rebuild switch --flake $working_path --show-trace
}
