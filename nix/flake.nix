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
    # bat syntaxes/themes
    sublime-nushell.url = "github:stevenxxiu/sublime_text_nushell";
    sublime-nushell.flake = false;
    sublime-tokyonight.url = "github:folke/tokyonight.nvim";
    sublime-tokyonight.flake = false;
    # tmux plugins
    tmux-sessionx.url = "github:omerxx/tmux-sessionx";
    tmux-sessionx.inputs.nixpkgs.follows = "nixpkgs";
    tmux-catppuccin.url = "github:catppuccin/tmux";
    tmux-catppuccin.flake = false;
    # homebrew
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    nix-homebrew.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.inputs.nix-darwin.follows = "nix-darwin";
    homebrew-bundle.url = "github:homebrew/homebrew-bundle";
    homebrew-bundle.flake = false;
    # secrets
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nix-darwin,
      nix-homebrew,
      home-manager,
      homebrew-bundle,
      ...
    }@inputs:
    let
      args = {
        inherit inputs;
        username = "farseerhe";
        hostname = "Hes-Mac-mini";
        arch = "aarch64-darwin";
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
              users."${args.username}" = ./hmModules/home.nix;
              extraSpecialArgs = args;
            };
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations.${args.hostname}.pkgs;
    };
}
