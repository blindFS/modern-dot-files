let
  colors = {
    black = "#111726";
    white = "#a3aed2";
    grey = "#394260";
    dark_grey = "#212736";
    blue = "#769ff0";
    yellow = "#e0af68";
    warn = "#ff4b14";
    red = "#f7768e";
    green = "#9ece6a";
    purple = "#bb9af7";
    light_red = "#ff899d";
    light_yellow = "#faba4a";
    light_blue = "#a4daff";
    light_green = "#0dcf6f";
    cyan = "#7dcfff";
    magenta = "#c7a9ff";
  };

  xargb-color = hex: builtins.replaceStrings [ "#" ] [ "0xff" ] hex;
  colors_xargb = builtins.mapAttrs (_: v: xargb-color v) colors;
in
{
  flake.theme = {
    inherit colors colors_xargb;
    colorscheme = "tokyonight_night";
    monofont = "IosevkaTerm Nerd Font Mono";
  };
}
