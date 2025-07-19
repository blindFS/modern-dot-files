{
  inputs,
  pkgs,
  username,
  hostname,
  arch,
  colorscheme,
  ...
}:
let
  cs = import ../colorscheme.nix {
    inherit colorscheme;
    xargb = true;
    alpha = "dd";
  };
in
{
  imports = [
    ./services/aerospace.nix
    ./services/borders.nix
  ];
  config = {
    environment.variables = {
      XDG_CONFIG_HOME = "/Users/${username}/.config";
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
      # emacs30
      eza
      fd
      ffmpeg
      fzf
      gh
      gotop
      graphviz
      helix
      home-manager
      ispell
      imagemagick
      jankyborders
      jc
      lazygit
      neovim
      nh
      nixd
      nixfmt-rfc-style
      nushell
      plistwatch
      ripgrep
      sesh
      sops
      starship
      # texliveMedium
      tig
      tldr
      tmux
      tree-sitter
      uv
      vivid
      yazi
      yt-dlp
      zoxide
    ];

    # manage nix's own config in /etc/nix/nix.conf
    nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    nix.settings = {
      substituters = [ "https://mirrors.ustc.edu.cn/nix-channels/store" ];
      experimental-features = "nix-command flakes pipe-operators";
      trusted-users = [
        "root"
        username
      ];
    };

    # fonts
    fonts.packages = [
      pkgs.nerd-fonts.iosevka
    ];

    # services
    services.sketchybar.enable = true;
    borders.KeepAlive = true;
    borders.active_color = cs.blue;
    borders.inactive_color = cs.dark_grey;

    # homebrew
    homebrew = import ./homebrew.nix;

    # Auto upgrade nix package and the daemon service.
    nix.package = pkgs.nix;

    # Create /etc/zshrc that loads the nix-darwin environment.
    programs.zsh.enable = true; # default shell on catalina
    # programs.fish.enable = true;

    # https://mynixos.com/nix-darwin/options/system.defaults
    networking.hostName = hostname;
    system.defaults = import ./system.nix;
    power.sleep.display = "never";

    # Set Git commit hash for darwin-version.
    system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    system.stateVersion = 5;
    system.primaryUser = username;

    # The platform the configuration will be used on.
    nixpkgs.hostPlatform = arch;

  };
}
