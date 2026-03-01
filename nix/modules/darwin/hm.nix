{
  lib,
  inputs,
  self,
  ...
}:
{
  imports = [
    # The flakeModule provides:
    # - flake.homeConfigurations option (for proper merging across modules)
    # - flake.homeModules option (for reusable modules)
    inputs.home-manager.flakeModules.home-manager
  ];

  flake.darwinModules.homeManager =
    { pkgs, ... }:
    {
      imports = [
        inputs.home-manager.darwinModules.home-manager
      ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit inputs self pkgs;
        };
        users.${self.identity.username} = {
          imports = [
            self.homeModules.ghostty
            self.homeModules.git
            self.homeModules.nh
            self.homeModules.security
            self.homeModules.shell
            self.homeModules.sketchybar
            self.homeModules.tmux
            self.homeModules.zed
            self.homeModules.config
          ];

          # Home Manager needs a bit of information about you and the
          # paths it should manage.
          home.username = self.identity.username;
          # TODO: get rid of mkForce
          home.homeDirectory = lib.mkForce /Users/${self.identity.username};

          # use XDG_CONFIG_HOME if set
          xdg.enable = true;

          home.sessionVariables.EDITOR = "nvim";
          home.stateVersion = "26.05";

          programs.home-manager.enable = true;
        };
      };
    };
}
