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
    tmux-catppuccin.url = "github:catppuccin/tmux";
    tmux-catppuccin.flake = false;
    # homebrew
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-bundle.url = "github:homebrew/homebrew-bundle";
    homebrew-bundle.flake = false;
  };

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
      nix-homebrew,
      home-manager,
      homebrew-bundle,
      sublime-nushell,
      sublime-tokyonight,
      tmux-sessionx,
      tmux-catppuccin,
    }@inputs:
    let
      username = "farseerhe";
      arch = "aarch64-darwin";
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."Hes-Mac-mini" = nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit inputs arch;
        };
        modules = [
          ./osModules
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
              users."${username}" = ./hmModules;
              extraSpecialArgs = {
                inherit inputs username arch;
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
