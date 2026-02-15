{
  flake.darwinModules.cli =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        aria2
        atuin
        carapace
        eza
        fd
        ffmpeg
        fzf
        gotop
        graphviz
        ispell
        imagemagick
        jc
        ripgrep
        sesh
        tldr
        uv
        vivid
        yazi
        yt-dlp
        zoxide
      ];
    };
}
