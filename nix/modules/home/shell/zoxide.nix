{
  flake.homeModules.zoxide =
    { ... }:
    {
      programs.zoxide.enable = true;
    };
}
