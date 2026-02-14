{
  lib,
  self,
  ...
}:
let
  username = self.identity.username;
in
{
  imports = [
    self.homeManagerModules.bat
    self.homeManagerModules.ghostty
    self.homeManagerModules.git
    self.homeManagerModules.nushell
    self.homeManagerModules.security
    self.homeManagerModules.sketchybar
    self.homeManagerModules.starship
    self.homeManagerModules.tmux
    self.homeManagerModules.zsh
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = username;
  home.homeDirectory = lib.mkForce "/Users/${username}";

  # use XDG_CONFIG_HOME if set
  xdg.enable = true;

  home.sessionVariables.EDITOR = "nvim";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
