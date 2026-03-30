{
  flake.darwinModules.fonts =
    { pkgs, ... }:
    {
      fonts.packages = [
        pkgs.nerd-fonts.iosevka-term
        # pkgs.maple-mono.NF
      ];
    };

  flake.font.monofont = "IosevkaTerm Nerd Font Mono";
  # flake.font.monofont = "Maple Mono NF";
}
