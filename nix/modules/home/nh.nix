{ self, ... }:
{
  flake.homeModules.nh = {
    programs.nh.enable = true;
    programs.nh.flake = "/Users/${self.identity.username}/nix";
  };
}
