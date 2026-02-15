{ inputs, self, ... }:
let
  topiary-nu = inputs.topiary-nu.packages.${self.identity.arch}.default;
in
{
  flake.darwinModules.dev =
    { pkgs, ... }:
    {
      # Editors, lang-chains
      environment.systemPackages = with pkgs; [
        elan
        # emacs30
        helix
        nixd
        nixfmt
        rustup
        topiary
        topiary-nu
        tree-sitter
        uv
      ];
    };
}
