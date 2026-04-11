{ self, ... }:
{
  flake.darwinModules.desktop =
    { ... }:
    {
      imports = with self.darwinModules; [
        aerospace
        # borders
        sketchybar
      ];
    };
}
