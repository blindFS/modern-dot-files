{ self, ... }:
{
  flake.darwinModules.desktop =
    { ... }:
    {
      imports = [
        self.darwinModules.aerospace
        self.darwinModules.borders
        self.darwinModules.sketchybar
      ];
    };
}
