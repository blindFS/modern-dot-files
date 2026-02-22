{ inputs, self, ... }:
{
  flake.darwinConfigurations.${self.identity.hostname} = inputs.nix-darwin.lib.darwinSystem {
    modules = [ self.darwinModules.hostModule ];
  };

  flake.darwinModules.hostModule =
    { ... }:
    {
      imports = [
        self.darwinModules.cli
        self.darwinModules.desktop
        self.darwinModules.dev
        self.darwinModules.fonts
        self.darwinModules.homeManager
        self.darwinModules.homebrew
        self.darwinModules.nix
        self.darwinModules.preferrence
      ];

      networking.hostName = self.identity.hostname;
      system.primaryUser = self.identity.username;
      system.stateVersion = 5;
    };
}
