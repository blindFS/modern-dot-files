{ inputs, self, ... }:
{
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
