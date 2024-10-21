## Nix-darwin

1. install nix, nix-darwin
2. `nix --experimental-features 'nix-command flakes' run nix-darwin -- switch --flake {FLAKEPATH}`
3. cd to FLAKEPATH, `nix flake update`
4. `darwin-rebuild switch --flake {FLAKEPATH} --show-trace`

