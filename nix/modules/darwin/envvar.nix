{ lib, self, ... }:
{
  flake.darwinModules.envvar =
    { ... }:
    {
      environment.variables = {
        XDG_CONFIG_HOME = "/Users/${self.identity.username}/.config";
      };

      environment.systemPath = self.paths;
      environment.etc."paths.d/100-nix".text = lib.concatStringsSep "\n" self.paths;
    };

  flake.paths = [
    "/opt/homebrew/bin"
    "/run/current-system/sw/bin"
    "/etc/profiles/per-user/${self.identity.username}/bin"
  ];
}
