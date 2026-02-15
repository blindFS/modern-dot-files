# Darwin flake-parts integration
# Uses official nix-darwin.flakeModules.default
{ inputs, ... }:
{
  # Define flake.darwinModules for merging
  # flake.nixosModules is provided by flake-parts
  # flake.homeModules is provided by home-manager.flakeModules.home-manager
  imports = [
    inputs.nix-darwin.flakeModules.default
    {
      options.flake.darwinModules = inputs.nixpkgs.lib.mkOption {
        type = inputs.nixpkgs.lib.types.lazyAttrsOf inputs.nixpkgs.lib.types.raw;
        default = { };
        description = "Darwin system modules.";
      };
    }
  ];
}
