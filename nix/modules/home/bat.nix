{ self, ... }:
{
  flake.homeManagerModules.bat = {
    programs.bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = self.theme.colorscheme;
      };
    };
  };
}
