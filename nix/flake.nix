{
  description = "BlindFS Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    # nix-darwin
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    # home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # homebrew
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    # secrets
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    # topiary-nushell
    topiary-nu.url = "github:blindFS/topiary-nushell";
    topiary-nu.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      let
        tree = inputs.import-tree ./modules;
      in
      {

        imports = tree.imports ++ [
          inputs.home-manager.flakeModules.home-manager
          inputs.nix-darwin.flakeModules.default
          {
            options.flake.darwinModules = inputs.nixpkgs.lib.mkOption {
              type = inputs.nixpkgs.lib.types.lazyAttrsOf inputs.nixpkgs.lib.types.raw;
              default = { };
              description = "Darwin modules to be exported from this flake.";
            };
          }
        ];

        flake = {
          # Host configurations are defined in modules/*
        };
      }
    );
}
