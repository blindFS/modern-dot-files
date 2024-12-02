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
    "diffusionbee"
    "discord"
    "dropbox"
    "iina"
    "karabiner-elements"
    "kicad"
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
