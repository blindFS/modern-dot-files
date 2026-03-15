{ inputs, self, ... }:
{
  flake.darwinModules.homebrew =
    { config, ... }:
    {
      imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

      # nix-homebrew configuration
      nix-homebrew = {
        enable = true;
        user = self.identity.username;
        enableRosetta = false;
        autoMigrate = true;
        mutableTaps = true;
      };

      homebrew = {
        enable = true;
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = false;
        onActivation.upgrade = false;

        brews = [
          "mole"
        ];
        casks = [
          "balenaetcher"
          "betterdisplay"
          "blender"
          "discord"
          "dropbox"
          "iloader"
          "kicad"
          "macs-fan-control"
          "openscad"
          "popclip"
          "steam"
          "yam-display"
        ];
      };

      environment.variables = {
        HOMEBREW_NO_AUTO_UPDATE = "1";
      };

      environment.systemPath = [
        "${config.homebrew.prefix}/bin"
      ];
    };
}
