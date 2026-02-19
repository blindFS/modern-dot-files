{
  flake.darwinModules.cli =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        aria2
        atuin
        eza
        fd
        ffmpeg
        gotop
        graphviz
        ispell
        imagemagick
        jc
        ripgrep
        tldr
        uv
        vivid
        yazi
        yt-dlp
        zoxide
      ];
    };
}
