{ inputs, self, ... }:
let
  topiary-nu = inputs.topiary-nu.packages.${self.identity.arch}.default;
in
{
  flake.darwinModules.homebrew = {
    homebrew.brews = [
      "cocoapods"
      "neovim"
      "node"
    ];
    homebrew.casks = [
      "flutter"
      "tailscale-app"
    ];
  };

  flake.darwinModules.dev =
    { pkgs, ... }:
    {
      # Editors, lang-chains
      environment.systemPackages = with pkgs; [
        elan
        # emacs30
        nixd
        nixfmt
        rustup
        sdcc
        topiary
        topiary-nu
        tree-sitter
        uv
      ];
    };
}
