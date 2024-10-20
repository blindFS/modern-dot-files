{
  description = "BlindFS Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-services = {
      url = "github:homebrew/homebrew-services";
      flake = false;
    };
    cask-fonts = {
      url = "github:laishulu/homebrew-cask-fonts";
      flake = false;
    };
  };

  outputs = inputs@{ self,
    nix-darwin,
    nixpkgs,
    nix-homebrew,
    homebrew-core,
    homebrew-cask,
    homebrew-services,
    cask-fonts,
    }:
    let
      configuration = { pkgs, ... }: {
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.variables = {
          XDG_CONFIG_HOME = "/Users/farseerhe/.config";
        };
        environment.systemPackages =
          [
            pkgs.atuin
            pkgs.bat
            pkgs.carapace
            pkgs.delta
            pkgs.eza
            pkgs.fd
            pkgs.ffmpeg
            pkgs.fzf
            pkgs.gotop
            pkgs.jankyborders
            pkgs.jc
            pkgs.lazygit
            pkgs.ncmpcpp
            pkgs.neovim
            pkgs.ripgrep
            pkgs.sketchybar
            pkgs.starship
            pkgs.thefuck
            pkgs.tig
            pkgs.tldr
            pkgs.vivid
            pkgs.yazi
            pkgs.zoxide
          ];

        homebrew = {
          taps = [
            {
              name = "nikitabobko/tap";
              clone_target = "https://github.com/nikitabobko/homebrew-tap.git";
              force_auto_update = true;
            }
            {
              name = "felixkratz/formulae";
              clone_target = "https://github.com/felixkratz/homebrew-formulae.git";
              force_auto_update = true;
            }
          ];
          brews = [
            "rust"
            "nushell"
            "tmux"
            "ipython"
            {
              name = "felixkratz/formulae/borders";
              restart_service = false;
            }
            {
              name = "felixkratz/formulae/sketchybar";
              restart_service = false;
            }
            {
              name = "mpd";
              restart_service = false;
            }
          ];
          casks = [
            "aerospace"
            "anki"
            "audacity"
            "balenaetcher"
            "dropbox"
            "emacs"
            "iina"
            "karabiner-elements"
            "kicad"
            "laishulu/cask-fonts/font-sarasa-nerd"
            "mactex-no-gui"
            "popclip"
            "stolendata-mpv"
            {
              name = "raycast";
              greedy = true;
            }
            "visual-studio-code"
            {
              name = "wezterm";
              greedy = true;
            }
          ];
          onActivation.cleanup = "zap";
          onActivation.autoUpdate = true;
          onActivation.upgrade = true;
          enable = true;
        };

        fonts.packages = [
          # (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })
        ];

        # Auto upgrade nix package and the daemon service.
        services.nix-daemon.enable = true;
        nix.package = pkgs.nix;

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        # Create /etc/zshrc that loads the nix-darwin environment.
        programs.zsh.enable = true;  # default shell on catalina
        # programs.fish.enable = true;

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 5;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "x86_64-darwin";
      };
    in
      {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."Farseers-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = false;
              user = "farseerhe";
              autoMigrate = false;
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/services" = homebrew-services;
                "laishulu/cask-fonts" = cask-fonts;
              };
              mutableTaps = true;
            };
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."Farseers-MacBook-Pro".pkgs;
    };
}
