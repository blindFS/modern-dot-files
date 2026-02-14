{
  inputs,
  self,
  ...
}:
{
  flake.darwinConfigurations.${self.identity.hostname} = inputs.nix-darwin.lib.darwinSystem {
    modules = [ self.darwinModules.hostModule ];
  };

  flake.darwinModules.hostModule =
    { ... }:
    {
      imports = [
        self.darwinModules.aerospace
        self.darwinModules.borders
        self.darwinModules.envvar
        self.darwinModules.fonts
        self.darwinModules.homeManager
        self.darwinModules.homebrew
        self.darwinModules.misc
        self.darwinModules.nix
        self.darwinModules.preferrence
        self.darwinModules.sketchybar
      ];

      networking.hostName = self.identity.hostname;
      system.primaryUser = self.identity.username;
      system.stateVersion = 5;
    };
}
