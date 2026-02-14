{
  flake.darwinModules.fonts =
    { pkgs, ... }:
    {
      fonts.packages = [
        pkgs.nerd-fonts.iosevka-term
        pkgs.nerd-fonts.fira-code
      ];

    };
}
