{
  enable = true;
  onActivation.cleanup = "zap";
  onActivation.autoUpdate = true;
  onActivation.upgrade = true;
  brews = [
    "atuin"
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
    "macs-fan-control"
    "popclip"
    "steam"
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
}
