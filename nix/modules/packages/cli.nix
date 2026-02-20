{
  flake.darwinModules.cli =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        aria2
        ffmpeg
        gotop
        graphviz
        ispell
        imagemagick
        jc
        ripgrep
        tldr
        uv
        yazi
        yt-dlp
      ];
    };
}
