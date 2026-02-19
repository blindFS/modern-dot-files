{ lib, self, ... }:
{
  flake.darwinModules.homebrew = {
    homebrew.casks = [ "ghostty" ];
  };

  flake.homeModules.ghostty =
    { pkgs, ... }:
    {
      programs.ghostty = {
        enable = true;
        # ghostty installed by homebrew
        package = null;
        settings = {
          # need to call zsh first in initial-command to load env variables set by nix
          initial-command = "zsh -l -c \"${lib.getExe pkgs.tmux} new -A -s dev\"";
          font-family = self.font.monofont;
          font-size = 15;
          theme = builtins.split "_" self.theme.colorscheme |> builtins.head;
          background-opacity = 0.8;
          background = "#000000";
          macos-titlebar-style = "hidden";
          custom-shader = "shaders/cursor_blaze.glsl";
          quit-after-last-window-closed = true;
        };
      };
    };
}
