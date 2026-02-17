{ self, ... }:
let
  username = self.identity.username;
  home = "/Users/${username}";
  config_home = "${home}/.config";
in
{
  flake.darwinModules.envvar =
    { ... }:
    {
      environment.variables = {
        HOME = home;
        XDG_CONFIG_HOME = config_home;
      };

      environment.systemPath = [
        "/opt/homebrew/bin"
        "/run/current-system/sw/bin"
        "/etc/profiles/per-user/${username}/bin"
      ];
    };
}
