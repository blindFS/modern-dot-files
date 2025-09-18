{
  colorscheme,
  ...
}:
{
  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      theme = colorscheme;
    };
  };
}
