{ inputs, self, ... }:
let
  topiary-nu = inputs.topiary-nu.packages.${self.identity.arch}.default;
in
{
  flake.darwinModules.misc =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        aria2
        atuin
        carapace
        # emacs30
        elan
        eza
        fd
        ffmpeg
        fzf
        gh
        gotop
        graphviz
        helix
        home-manager
        ispell
        imagemagick
        jc
        nh
        nixd
        nixfmt
        plistwatch
        ripgrep
        rustup
        sesh
        # texliveMedium
        tldr
        topiary
        topiary-nu
        tree-sitter
        uv
        vivid
        yazi
        yt-dlp
        zoxide
      ];
    };
}
