{ self, ... }:
{
  flake.darwinModules.envvar = {
    environment.variables = {
      XDG_CONFIG_HOME = "/Users/${self.identity.username}/.config";
    };

    # TODO: Add binary path to /etc/paths, manually handled now.
    environment.systemPath = [
      "/opt/homebrew/bin"
      "/run/current-system/sw/bin"
      "/etc/profiles/per-user/${self.identity.username}/bin"
    ];
  };
}
