{
  description = "BlindFS Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
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
      homebrew-bundle,
    }:
    let
      pkgs = import nixpkgs { system = "aarch64-darwin"; };
      aero-settings = import ./aerospace.nix { inherit pkgs; };
      borders-settings = import ./borders.nix { inherit pkgs; };
      homebrew-settings = import ./homebrew.nix;
      sys-settings = import ./system.nix;
      configuration =
        { pkgs, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.variables = {
            XDG_CONFIG_HOME = "/Users/farseerhe/.config";
          };
          # TODO: Add binary path to /etc/paths, manually handled now.
          environment.systemPath = [
            "/opt/homebrew/bin"
            "/run/current-system/sw/bin"
          ];
          environment.systemPackages = with pkgs; [
            aria2
            bat
            carapace
            delta
            emacs30
            eza
            fd
            ffmpeg
            fzf
            gh
            gotop
            graphviz
            ispell
            jankyborders
            jc
            lazygit
            neovim
            nixd
            nixfmt-rfc-style
            ripgrep
            starship
            texliveMedium
            thefuck
            tig
            tldr
            tmux
            tree-sitter
            vivid
            yazi
            yt-dlp
            zoxide
          ];

          # fonts
          fonts.packages = [
            pkgs.nerd-fonts.iosevka
          ];

          # services
          services.aerospace = {
            enable = true;
            settings = aero-settings;
          };
          services.sketchybar.enable = true;
          launchd.user.agents.borders = borders-settings;

          # homebrew
          homebrew = homebrew-settings;

          # Auto upgrade nix package and the daemon service.
          services.nix-daemon.enable = true;
          nix.package = pkgs.nix;

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Create /etc/zshrc that loads the nix-darwin environment.
          programs.zsh.enable = true; # default shell on catalina
          # programs.fish.enable = true;

          # https://mynixos.com/nix-darwin/options/system.defaults
          system.defaults = sys-settings;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 5;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."Hes-Mac-mini" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = false;
              user = "farseerhe";
              autoMigrate = true;
              taps = {
                "homebrew/bundle" = homebrew-bundle;
              };
              # mutableTaps = true;
              mutableTaps = false;
            };
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."Hes-Mac-mini".pkgs;
    };
}
