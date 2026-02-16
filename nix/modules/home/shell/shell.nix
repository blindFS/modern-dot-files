{ self, ... }:
{
  flake.homeModules.shell = {
    imports = [
      self.homeModules.carapace
      self.homeModules.nushell
      self.homeModules.starship
      self.homeModules.zsh
    ];
  };
}
