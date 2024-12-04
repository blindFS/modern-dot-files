{
  inputs,
  arch,
  ...
}:
let
  pkgs = import inputs.nixpkgs { system = arch; };
in
{
  imports = [
    ./services/aerospace.nix
    ./services/borders.nix
  ];
  config = {
    environment.variables = {
      XDG_CONFIG_HOME = builtins.getEnv "HOME" + "/.config";
    };

    # TODO: Add binary path to /etc/paths, manually handled now.
    environment.systemPath = [
      "/opt/homebrew/bin"
      "/run/current-system/sw/bin"
    ];

    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    environment.systemPackages = with pkgs; [
      aria2
      atuin
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
      home-manager
      ispell
      jankyborders
      jc
      lazygit
      neovim
      nixd
      nixfmt-rfc-style
      nushell
      ripgrep
      sesh
      starship
      texliveMedium
      thefuck
      tig
      tldr
      tmux
      tree-sitter
      vivid
      wezterm
      yazi
      yt-dlp
      zoxide
    ];

    nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    # fonts
    fonts.packages = [
      pkgs.nerd-fonts.iosevka
    ];

    # services
    services.sketchybar.enable = true;
    borders.KeepAlive = true;

    # homebrew
    homebrew = import ./homebrew.nix;

    # Auto upgrade nix package and the daemon service.
    services.nix-daemon.enable = true;
    nix.package = pkgs.nix;

    # Necessary for using flakes on this system.
    nix.settings.experimental-features = "nix-command flakes";

    # Create /etc/zshrc that loads the nix-darwin environment.
    programs.zsh.enable = true; # default shell on catalina
    # programs.fish.enable = true;

    # https://mynixos.com/nix-darwin/options/system.defaults
    system.defaults = import ./system.nix;

    # Set Git commit hash for darwin-version.
    system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    system.stateVersion = 5;

    # The platform the configuration will be used on.
    nixpkgs.hostPlatform = arch;

  };
}
