{ self, ... }:
let
  cs = self.theme.colors;
in
{
  flake.homeModules.git =
    { ... }:
    {
      programs.git = {
        enable = true;
        settings = {
          user = {
            name = "blindfs";
            email = "blindfs19@gmail.com";
          };
          alias = {
            pb = "pull --rebase";
            st = "status";
            co = "commit -m";
            cmsg = "commit --amend -m";
            all = "add --all .";
            au = "add -u";
            lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --";
            url = "config --get remote.origin.url";
          };
        };
      };

      programs.delta = {
        enable = true;
        enableGitIntegration = true;
        options = {
          navigate = true;
          syntax-theme = self.theme.colorscheme;
          line-numbers = true;
          side-by-side = false;
          diff-so-fancy = true;
          minus-style = "syntax strike ${cs.dark_grey}";
          plus-style = "syntax ${cs.grey}";
          line-numbers-minus-style = "bold red";
          line-numbers-plus-style = "bold green";
        };
      };

      programs.lazygit = {
        enable = true;
        enableNushellIntegration = false;
        settings = {
          gui.nerdFontsVersion = "3";
          git.pagers = [
            {
              pager = "delta --paging=never";
              colorArg = "always";
            }
          ];
        };
      };

      programs.gh.enable = true;
    };
}
