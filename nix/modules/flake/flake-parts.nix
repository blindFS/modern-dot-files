{ inputs, self, ... }:
{
  imports = [ inputs.flake-parts.flakeModules.modules ];

  # for nixd completion
  debug = true;

  systems = [
    self.identity.arch
  ];
}
