{ pkgs, ... }:
let
  width = "6.0";
  active_color = "0xdd7aa2f7";
  inactive_color = "0xdd494d64";
in
{
  serviceConfig = {
    ProgramArguments = [
      "${pkgs.jankyborders}/bin/borders"
      "hidpi=on"
      "width=${width}"
      "active_color=${active_color}"
      "inactive_color=${inactive_color}"
    ];
    KeepAlive = false;
    RunAtLoad = true;
  };
}
