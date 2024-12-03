{
  description = "BlindFS Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # Optional: Declarative tap management
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
      nix-homebrew,
      home-manager,
      homebrew-bundle,
    }:
    let
      username = "farseerhe";
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."Hes-Mac-mini" = nix-darwin.lib.darwinSystem {
        modules = [
          (import ./packages/config.nix { inherit self nixpkgs; })
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              user = username;
              enableRosetta = true;
              autoMigrate = true;
              taps."homebrew/bundle" = homebrew-bundle;
              # mutableTaps = true;
              mutableTaps = false; # functional homebrew
            };
          }
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users."${username}" = import ./home/home.nix;
              extraSpecialArgs = {
                username = username;
                colorscheme = "tokyonight_night";
                monofont = "Iosevka Nerd Font Mono";
              };
            };
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."Hes-Mac-mini".pkgs;
    };
}
