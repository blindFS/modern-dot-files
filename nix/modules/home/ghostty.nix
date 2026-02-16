{ lib, self, ... }:
{
  flake.darwinModules.homebrewGhostty = {
    homebrew.casks = [ "ghostty" ];
  };

  flake.homeModules.ghostty =
    { pkgs, ... }:
    {
      xdg.configFile."ghostty/config".text = ''
        initial-command = ${lib.getExe pkgs.tmux} new -A -s dev
        font-family = "${self.font.monofont}"
        font-size = 15
        theme = "${builtins.split "_" self.theme.colorscheme |> builtins.head}"
        background-opacity = 0.8
        background = #000000
        macos-titlebar-style = hidden
        custom-shader = shaders/cursor_blaze.glsl
        quit-after-last-window-closed = true
      '';
    };
}
