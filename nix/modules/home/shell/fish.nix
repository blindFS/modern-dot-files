{ self, ... }:
{
  flake.homeModules.fish =
    { pkgs, ... }:
    {
      # Overrides invalid man config introduced with fish
      programs.man = {
        package = null;
        generateCaches = false;
      };

      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          set -g fish_greeting ""
          set -g fish_pager_color_progress white --background=brblack
          fish_vi_key_bindings

          # Have to source it manually because the following `binds` attribute overrides all keybindings
          source $__fish_config_dir/conf.d/plugin-autopair.fish
        '';
        shellAliases = self.shellAliases;
        binds = {
          "ctrl-e" = {
            mode = "insert";
            command = [
              "accept-autosuggestion"
              "end-of-buffer"
            ];
          };
          "ctrl-p" = {
            mode = "insert";
            command = "history-search-backward";
          };
          "ctrl-n" = {
            mode = "insert";
            command = "history-search-forward";
          };
          "ctrl-a" = {
            mode = "insert";
            command = "beginning-of-buffer";
          };
        };
        plugins = [
          {
            name = "autopair";
            src = pkgs.fishPlugins.autopair.src;
          }
        ];
      };
    };
}
