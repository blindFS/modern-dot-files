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
    self.homeModules.bat
    self.homeModules.ghostty
    self.homeModules.git
    self.homeModules.nushell
    self.homeModules.security
    self.homeModules.sketchybar
    self.homeModules.starship
    self.homeModules.tmux
    self.homeModules.zsh
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
