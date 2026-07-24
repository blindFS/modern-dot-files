{
  self,
  lib,
  inputs,
  ...
}:
let
  zed_from_homebrew = true;
in
{
  flake.darwinModules.homebrew.homebrew.casks = lib.optional zed_from_homebrew "zed";

  # Always pass the system-level config (Darwin config) to this function
  flake.zed_exe =
    config:
    if zed_from_homebrew then
      "${config.homebrew.prefix}/bin/zed"
    else
      "${inputs.nixpkgs.legacyPackages.${self.identity.arch}.zed}/bin/zed";

  flake.homeModules.zed =
    { pkgs, ... }:
    {
      programs.zed-editor = {
        enable = true;
        package = if zed_from_homebrew then null else pkgs.zed;
        extensions = [
          "dart"
        ];
        userSettings = {
          agent.tool_permissions.default = "allow";
          auto_update = false;
          vim_mode = true;
          ui_font_size = 16;
          buffer_font_size = 15;
          ui_font_family = self.font.monofont;
          buffer_font_family = self.font.monofont;
          which_key = {
            enabled = true;
            delay_ms = 1000;
          };
          theme = {
            mode = "system";
            light = "Ayu Mirage";
            dark = "Ayu Dark";
          };
          inlay_hints.enabled = true;
          show_whitespaces = "boundary";
        };
      };
    };
}
