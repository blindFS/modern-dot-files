{ self, ... }:
{
  flake.homeModules.fish =
    { ... }:
    {
      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          fish_vi_key_bindings
          set -g fish_greeting ""
        '';
        shellAliases = self.shellAliases;
      };
    };
}
