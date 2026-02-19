{
  flake.homeModules.eza =
    { ... }:
    {
      programs.eza = {
        enable = true;
        enableNushellIntegration = false;
        enableZshIntegration = false;
        colors = "always";
        icons = "always";
      };
    };
}
