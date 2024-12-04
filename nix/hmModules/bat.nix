{
  colorscheme,
  inputs,
  ...
}:
{
  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      theme = colorscheme;
    };
    syntaxes = {
      nushell = {
        src = inputs.sublime-nushell;
        file = "nushell.sublime-syntax";
      };
    };
    themes = {
      tokyonight_night = {
        src = inputs.sublime-tokyonight;
        file = "extras/sublime/tokyonight_night.tmTheme";
      };
    };
  };
}
