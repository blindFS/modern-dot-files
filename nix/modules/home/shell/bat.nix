{ self, ... }:
let
  cs = self.theme.colorscheme;
in
{
  flake.homeModules.bat =
    { ... }:
    {
      programs.bat = {
        enable = true;
        config = {
          pager = "less -FR";
          theme = cs;
        };
        themes."${cs}".src = ../../theme/${cs}.tmTheme;
      };
    };
}
