{
  self,
  inputs,
  lib,
  ...
}:
let
  # Media change event listener
  media_watcher_script = "sketchybar/plugins/media_watcher.nu";
  sketchybar_from_homebrew = true;
in
{
  flake.darwinModules.homebrew.homebrew.brews = [
    "media-control"
  ]
  ++ (lib.optional sketchybar_from_homebrew "FelixKratz/formulae/sketchybar");

  flake.sketchybar_exe =
    config:
    if sketchybar_from_homebrew then
      "${config.homebrew.prefix}/bin/sketchybar"
    else
      "${inputs.nixpkgs.legacyPackages.${self.identity.arch}.sketchybar}/bin/sketchybar";

  flake.darwinModules.sketchybar =
    { config, ... }:
    {
      services.sketchybar.enable = !sketchybar_from_homebrew;
      # Run the media change event listener as a service
      launchd.user.agents.media-watcher = {
        serviceConfig = {
          ProgramArguments = [
            (self.nushell_exe config)
            "-n"
            "--no-std-lib"
            "${config.home-manager.users.${self.identity.username}.xdg.configHome}/${media_watcher_script}"
          ];
          KeepAlive = true;
          RunAtLoad = true;
        };
      };
    }
    // (lib.optionalAttrs sketchybar_from_homebrew {
      launchd.user.agents.sketchybar = {
        path = [ config.environment.systemPath ];
        serviceConfig = {
          ProgramArguments = [
            (self.sketchybar_exe config)
            "--config"
            "${config.home-manager.users.${self.identity.username}.xdg.configHome}/sketchybar/sketchybarrc"
          ];
          KeepAlive = true;
          RunAtLoad = true;
        };
      };
    });

  flake.homeModules.sketchybar =
    { osConfig, ... }:
    let
      cs = self.theme.colors_xargb;
      color-alpha = hex: alpha: builtins.replaceStrings [ "0xff" ] [ "0x${alpha}" ] hex;
      sketchybar_exe = self.sketchybar_exe osConfig;
    in
    {
      xdg.configFile.${media_watcher_script}.text =
        # nu
        ''
          ${osConfig.homebrew.prefix}/bin/media-control stream --debounce=200
            | each {
              if ($in | str contains playing) {
                ${sketchybar_exe} --trigger my_media_change;
                null
              }
            }
        '';

      xdg.configFile."sketchybar/plugins/style.nu".text =
        # nu
        ''
          # type int
          export const colors = {
            fg: 0x88ffffff
            bg: 0x55000000
            white: 0xffffffff
            black: 0xff000000
            dark: 0xcc000000
            transparent: 0x00000000
            yellow: ${cs.yellow}
            cyan: ${cs.cyan}
            blue: ${color-alpha cs.blue "dd"}
            green: ${cs.light_green}
            orange: ${cs.red}
            purple: ${cs.purple}
          }
          # type string
          export const mode_colors = {
            main: '${color-alpha cs.blue "dd"}'
            operation: '${cs.red}'
            resize: '${cs.light_green}'
            service: '${cs.white}'
          }
          export const monofont = '${self.font.monofont}'
        '';
    };
}
