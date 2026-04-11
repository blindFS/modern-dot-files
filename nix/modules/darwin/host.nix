{ inputs, self, ... }:
{
  flake.darwinConfigurations.${self.identity.hostname} = inputs.nix-darwin.lib.darwinSystem {
    modules = [ self.darwinModules.hostModule ];
  };

  flake.darwinModules.hostModule =
    { ... }:
    {
      imports = with self.darwinModules; [
        cli
        desktop
        dev
        fonts
        homeManager
        homebrew
        nix
        preferrence
        raycast
      ];

      networking.hostName = self.identity.hostname;
      system.primaryUser = self.identity.username;
      system.stateVersion = 5;
    };
}
