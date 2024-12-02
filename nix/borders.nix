{ pkgs, ... }:
let
  width = "6.0";
  active_color = "0xdd7aa2f7";
  inactive_color = "0xdd494d64";
in
{
  command = "${pkgs.jankyborders}/bin/borders width=${width} hidpi=on active_color=${active_color} inactive_color=${inactive_color}";
  serviceConfig = {
    KeepAlive = false;
    RunAtLoad = true;
  };
}
