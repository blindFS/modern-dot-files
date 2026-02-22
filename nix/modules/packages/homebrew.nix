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
          "steipete/tap/remindctl"
        ];
        casks = [
          "balenaetcher"
          "betterdisplay"
          "blender"
          "discord"
          "dropbox"
          "google-chrome"
          "iloader"
          "karabiner-elements"
          "kicad"
          "macs-fan-control"
          "openscad"
          "popclip"
          "raycast"
          "steam"
          "yam-display"
        ];
      };

      environment.variables.HOMEBREW_NO_AUTO_UPDATE = "1";

      environment.systemPath = [
        "${config.homebrew.prefix}/bin"
      ];
    };
}
