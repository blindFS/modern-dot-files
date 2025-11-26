{
  description = "BlindFS Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
    {
      self,
      nix-darwin,
      nix-homebrew,
      home-manager,
      ...
    }@inputs:
    let
      arch = "aarch64-darwin";
      pkgs = import inputs.nixpkgs { system = arch; };
      args = {
        inherit
          inputs
          pkgs
          arch
          ;
        username = "farseerhe";
        hostname = "Hes-Mac-mini";
        colorscheme = "tokyonight_night";
        monofont = "Iosevka Nerd Font Mono";
      };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations.${args.hostname} = nix-darwin.lib.darwinSystem {
        specialArgs = args;
        modules = [
          ./osModules
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              user = args.username;
              enableRosetta = false;
              autoMigrate = true;
              # mutableTaps = true;
              # mutableTaps = false; # functional homebrew
            };
          }
        ];
      };

      homeConfigurations = {
        "${args.username}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = args;
          modules = [ ./hmModules/home.nix ];
        };
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations.${args.hostname}.pkgs;
    };
}
