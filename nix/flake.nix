{
  description = "BlindFS Darwin system flake";
  nixConfig = {
    trusted-substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
    ];
  };

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
    # homebrew-services = {
    #   url = "github:homebrew/homebrew-services";
    #   flake = false;
    # };
    cask-fonts = {
      url = "github:laishulu/homebrew-cask-fonts";
      flake = false;
    };
    aerospace-tap = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nix-homebrew,
      homebrew-bundle,
      # homebrew-services,
      cask-fonts,
      aerospace-tap,
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.variables = {
            XDG_CONFIG_HOME = "/Users/farseerhe/.config";
          };
          # TODO: Add binary path to /etc/paths, manually handled now.
          # environment.systemPath = [
          # "/run/current-system/sw/bin/"
          # ];
          environment.systemPackages = [
            pkgs.atuin
            pkgs.bat
            pkgs.carapace
            pkgs.delta
            pkgs.emacs30
            pkgs.eza
            pkgs.fd
            pkgs.ffmpeg
            pkgs.fzf
            pkgs.gotop
            pkgs.graphviz
            pkgs.ispell
            pkgs.jankyborders
            pkgs.jc
            pkgs.lazygit
            # pkgs.ncmpcpp
            pkgs.neovim
            pkgs.nixd
            pkgs.nixfmt-rfc-style
            pkgs.ripgrep
            pkgs.sketchybar
            pkgs.starship
            pkgs.texliveMedium
            pkgs.thefuck
            pkgs.tig
            pkgs.tldr
            pkgs.tmux
            pkgs.vivid
            pkgs.yazi
            pkgs.yt-dlp
            pkgs.zoxide
          ];

          homebrew = {
            enable = true;
            # taps = builtins.attrNames config.nix-homebrew.taps;
            onActivation.cleanup = "zap";
            onActivation.autoUpdate = true;
            onActivation.upgrade = true;
            brews = [
              # {
              #   name = "mpd";
              #   restart_service = false;
              # }
              "nushell"
              "rust"
              "node"
              "ipython"
            ];
            casks = [
              "balenaetcher"
              "bilibili"
              "blender"
              "dropbox"
              "iina"
              "karabiner-elements"
              "kicad"
              "laishulu/cask-fonts/font-sarasa-nerd"
              "nikitabobko/tap/aerospace"
              "popclip"
              "sfm"
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
          };

          fonts.packages = [
            # (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })
          ];

          # Auto upgrade nix package and the daemon service.
          services.nix-daemon.enable = true;
          nix.package = pkgs.nix;
          nix.settings.substituters = [
            "https://mirrors.ustc.edu.cn/nix-channels/store"
            "https://cache.nixos.org/"
          ];

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Create /etc/zshrc that loads the nix-darwin environment.
          programs.zsh.enable = true; # default shell on catalina
          # programs.fish.enable = true;

          # https://mynixos.com/nix-darwin/options/system.defaults
          system.defaults = {
            dock.autohide = true;
            dock.orientation = "left";
            finder.AppleShowAllFiles = true;
            finder.QuitMenuItem = true;
            NSGlobalDomain.AppleInterfaceStyle = "Dark";
            NSGlobalDomain._HIHideMenuBar = true;
            NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;
          };

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
              autoMigrate = true;
              taps = {
                "laishulu/cask-fonts" = cask-fonts;
                "nikitabobko/tap" = aerospace-tap;
                # "homebrew/services" = homebrew-services;
                "homebrew/bundle" = homebrew-bundle;
              };
              # mutableTaps = true;
              mutableTaps = false;
            };
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."Farseers-MacBook-Pro".pkgs;
    };
}
