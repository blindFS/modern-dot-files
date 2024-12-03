{ pkgs, colorscheme, ... }:
{
  enable = true;
  config = {
    pager = "less -FR";
    theme = colorscheme;
  };
  syntaxes = {
    nushell = {
      src = pkgs.fetchFromGitHub {
        owner = "stevenxxiu";
        repo = "sublime_text_nushell";
        rev = "master";
        hash = "sha256-paayZP6P+tzGnla7k+HrF+dcTKUyU806MTtUeurhvdg=";
      };
      file = "nushell.sublime-syntax";
    };
  };
  themes = {
    tokyonight_night = {
      src = pkgs.fetchFromGitHub {
        owner = "folke";
        repo = "tokyonight.nvim";
        rev = "main";
        hash = "sha256-qeM5JQ8A7glbXqhPnM6h7TGk9IO0ikaRlW2wSO0ZQXU=";
      };
      file = "extras/sublime/tokyonight_night.tmTheme";
    };
  };
}
