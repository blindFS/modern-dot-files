{ inputs, self, ... }:
{
  flake.darwinModules.homebrew = {
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
        "neovim"
        "node"
        "mole"
        "gemini-cli"
        "openclaw-cli"
        "steipete/tap/remindctl"
      ];
      casks = [
        "balenaetcher"
        "betterdisplay"
        "blender"
        "discord"
        "dropbox"
        "google-chrome"
        "karabiner-elements"
        "kicad"
        "macs-fan-control"
        "openscad"
        "popclip"
        "raycast"
        "steam"
        "yam-display"
        "zed"
      ];
    };
  };
}
