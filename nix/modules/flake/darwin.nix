# Darwin flake-parts integration
# Uses official nix-darwin.flakeModules.default
{ lib, inputs, ... }:
{
  # Define flake.darwinModules for merging
  # flake.nixosModules is provided by flake-parts
  # flake.homeModules is provided by home-manager.flakeModules.home-manager
  imports = [
    inputs.nix-darwin.flakeModules.default
    {
      options.flake.darwinModules = inputs.nixpkgs.lib.mkOption {
        # type = lib.types.lazyAttrsOf inputs.nixpkgs.lib.types.raw;
        type = lib.types.attrsOf lib.types.deferredModule;
        default = { };
        description = "Darwin system modules.";
      };
    }
  ];
}
