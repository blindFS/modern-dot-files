{
  flake.homeModules.nh =
    { config, ... }:
    {
      programs.nh.enable = true;
      programs.nh.flake = "${config.home.homeDirectory}/nix";
    };
}
