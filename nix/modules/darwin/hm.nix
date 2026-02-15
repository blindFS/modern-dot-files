{ inputs, self, ... }:
{
  imports = [
    # The flakeModule provides:
    # - flake.homeConfigurations option (for proper merging across modules)
    # - flake.homeModules option (for reusable modules)
    inputs.home-manager.flakeModules.home-manager
  ];

  flake.darwinModules.homeManager =
    { pkgs, ... }:
    {
      imports = [
        inputs.home-manager.darwinModules.home-manager
      ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit inputs self pkgs;
        };
        users.${self.identity.username} = import ../home/_base/home.nix;
      };
    };
}
