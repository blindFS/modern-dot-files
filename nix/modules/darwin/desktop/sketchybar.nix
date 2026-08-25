{
  self,
  inputs,
  lib,
  ...
}:
let
  # Media change event listener
  media_watcher_script = "sketchybar/plugins/media_watcher.sh";
  sketchybar_from_homebrew = true;
in
{
  flake.darwinModules.homebrew.homebrew.brews = [
    "ifstat"
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
            "/bin/bash"
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
        # bash
        ''
          ${osConfig.homebrew.prefix}/bin/media-control stream --debounce=200
          | while IFS=read -r line; do
              if [[ "$line" == *"playing"* ]]; then
                ${sketchybar_exe} --trigger my_media_change
              fi
            done
        '';

      xdg.configFile."sketchybar/plugins/style.sh".text =
        # bash
        ''
          export COLOR_FG="0x88ffffff"
          export COLOR_BG="0x55000000"
          export COLOR_WHITE="0xffffffff"
          export COLOR_BLACK="0xff000000"
          export COLOR_DARK="0xcc000000"
          export COLOR_TRANSPARENT="0x00000000"
          export COLOR_YELLOW="${cs.yellow}"
          export COLOR_CYAN="${cs.cyan}"
          export COLOR_BLUE="${color-alpha cs.blue "dd"}"
          export COLOR_GREEN="${cs.green}"
          export COLOR_ORANGE="${cs.red}"
          export COLOR_PURPLE="${cs.purple}"

          export MONOFONT="${self.font.monofont}"
        '';
    };
}
