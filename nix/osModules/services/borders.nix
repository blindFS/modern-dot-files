{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    borders.width = lib.mkOption { default = "6.0"; };
    borders.active_color = lib.mkOption { default = "0xddffffff"; };
    borders.inactive_color = lib.mkOption { default = "0xdd000000"; };
    borders.KeepAlive = lib.mkOption { default = false; };
  };

  config = {
    launchd.user.agents.borders = {
      serviceConfig = {
        ProgramArguments = [
          "${pkgs.jankyborders}/bin/borders"
          "hidpi=on"
          "width=${config.borders.width}"
          "active_color=${config.borders.active_color}"
          "inactive_color=${config.borders.inactive_color}"
        ];
        KeepAlive = config.borders.KeepAlive;
        RunAtLoad = true;
      };
    };
  };
}
