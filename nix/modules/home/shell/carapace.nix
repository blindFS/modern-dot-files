{ lib, ... }:
let
  suffix = "/zsh/site-functions";
in
{
  flake.homeModules.carapace =
    { osConfig, ... }:
    {
      programs.carapace.enable = true;
      # manually handled
      programs.carapace.enableNushellIntegration = false;

      xdg.configFile."carapace/bridge/zsh/.zshrc" = {
        text =
          # sh
          ''
            for profile in ''${(z)NIX_PROFILES}; do
              local fp=$profile/share${suffix}
              # follow symlinks
              fpath+=(''${fp:A})
            done

            fpath+=($XDG_CONFIG_HOME/carapace/bridge${suffix})
            ${lib.optionalString (
              lib.hasAttr "homebrew" osConfig && osConfig.homebrew.enable
            ) "fpath+=(${osConfig.homebrew.prefix}${suffix})"}

            autoload -U compinit && compinit
          '';
        onChange = "carapace --clear-cache";
      };

      home.sessionVariables = {
        CARAPACE_LENIENT = "1";
        CARAPACE_BRIDGES = "zsh";
      };
    };
}
