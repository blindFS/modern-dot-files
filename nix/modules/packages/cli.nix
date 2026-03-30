{
  flake.darwinModules.cli =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        aria2
        ffmpeg
        gotop
        graphviz
        imagemagick
        ispell
        jc
        pokemon-colorscripts
        ripgrep
        tldr
        unar
        uv
        yazi
      ];
    };
}
