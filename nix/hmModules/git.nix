{ colorscheme, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "blindfs";
        email = "blindfs19@gmail.com";
      };
      aliases = {
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
    options = {
      navigate = true;
      side-by-side = false;
      syntax-theme = colorscheme;
      diff-so-fancy = true;
      line-numbers-minus-style = "bold red";
      line-numbers-plus-style = "bold green";
    };
  };
}
