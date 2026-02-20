{
  flake.homeModules.eza =
    { ... }:
    {
      programs.eza = {
        enable = true;
        enableNushellIntegration = false;
        colors = "always";
        icons = "always";
      };
    };
}
