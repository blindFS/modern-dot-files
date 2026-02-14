{ inputs, self, ... }:
{
  imports = [ inputs.flake-parts.flakeModules.modules ];

  config = {
    systems = [
      self.identity.arch
    ];
  };
}
