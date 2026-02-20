{
  flake.homeModules.nh =
    { osConfig, ... }:
    {
      programs.nh.enable = true;
      programs.nh.flake = "${osConfig.environment.variables.HOME}/nix";
    };
}
