{
  flake.homeModules.nh = {
    programs.nh.enable = true;
    programs.nh.flake = "${builtins.getEnv "HOME"}/nix";
  };
}
