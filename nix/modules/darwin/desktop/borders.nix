{ self, ... }:
let
  cs = self.theme.colors_xargb;
  color-alpha = hex: alpha: builtins.replaceStrings [ "0xff" ] [ "0x${alpha}" ] hex;
  width = "6";
  active_color = color-alpha cs.blue "dd";
  inactive_color = color-alpha cs.dark_grey "dd";
in
{
  flake.darwinModules.borders =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.jankyborders ];
      launchd.user.agents.borders = {
        serviceConfig = {
          ProgramArguments = [
            "${pkgs.jankyborders}/bin/borders"
            "hidpi=on"
            "width=${width}"
            "active_color=${active_color}"
            "inactive_color=${inactive_color}"
          ];
          KeepAlive = true;
          RunAtLoad = true;
        };
      };
    };
}
