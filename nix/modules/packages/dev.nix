{ ... }:
{
  flake.darwinModules.homebrew = {
    homebrew.brews = [
      "cocoapods"
      "neovim"
      "node"
    ];
    homebrew.casks = [
      # "flutter"
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
        tree-sitter
        typst
        uv
      ];
      # Fish completions
      programs.fish.enable = true;
    };
}
