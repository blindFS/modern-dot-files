{ self, ... }:
{
  flake.homeModules.shell = {
    imports = [
      self.homeModules.atuin
      self.homeModules.bat
      self.homeModules.carapace
      self.homeModules.fzf
      self.homeModules.nushell
      self.homeModules.starship
      self.homeModules.vivid
      self.homeModules.zoxide
      self.homeModules.zsh
    ];
  };
}
