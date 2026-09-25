{
  inputs,
  self,
  ...
}:
{
  flake.darwinModules.homebrew.homebrew.casks = [
    "bambu-studio"
    "openscad@snapshot"
  ];

  flake.darwinModules.openscad = { config, ... }: {
    environment.variables = {
      OPENSCADPATH = "${config.home-manager.users.${self.identity.username}.xdg.configHome}/OpenSCAD/";
    };
  };

  flake.homeModules.openscad =
    { config, ... }:
    {
      xdg.configFile."OpenSCAD/BOSL2".source = inputs.bosl2;
      home.file."Documents/OpenSCAD/libraries" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/OpenSCAD";
      };
    };
}
