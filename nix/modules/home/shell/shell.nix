{ self, ... }:
{
  flake.shellAliases = {
    boc = "brew outdated --cask --greedy";
    vim = "nvim";
  };

  flake.homeModules.shell = {
    imports = [
      self.homeModules.atuin
      self.homeModules.bat
      self.homeModules.carapace
      self.homeModules.fish
      self.homeModules.fzf
      self.homeModules.nushell
      self.homeModules.starship
      self.homeModules.vivid
      self.homeModules.zoxide
      self.homeModules.zsh
    ];
  };
}
