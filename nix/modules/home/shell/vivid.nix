{ self, ... }:
{
  flake.homeModules.vivid =
    { ... }:
    {
      programs.vivid.enable = true;
      programs.vivid.activeTheme = builtins.replaceStrings [ "_" ] [ "-" ] self.theme.colorscheme;
    };
}
