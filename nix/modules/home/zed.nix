{ self, ... }:
{
  flake.darwinModules.homebrew = {
    homebrew.casks = [ "zed" ];
  };

  flake.homeModules.zed =
    { ... }:
    {
      programs.zed-editor = {
        enable = true;
        # installed via homebrew
        package = null;
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
        };
      };
    };
}
