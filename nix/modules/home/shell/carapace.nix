{ lib, ... }:
{
  flake.homeModules.carapace =
    { pkgs, ... }:
    {
      xdg.configFile."carapace/bridge/zsh/.zshrc" = {
        text =
          # sh
          ''
            fpath=(/run/current-system/sw/share/zsh/site-functions \
              /opt/homebrew/share/zsh/site-functions \
              $XDG_CONFIG_HOME/carapace/bridge/zsh/site-functions \
              $fpath)
            autoload -U compinit && compinit
          '';
        onChange = "${lib.getExe pkgs.carapace} --clear-cache";
      };
    };
}
