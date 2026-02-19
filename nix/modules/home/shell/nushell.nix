{ self, ... }:
{
  flake.darwinModules.homebrew = {
    homebrew.brews = [ "nushell" ];
  };

  flake.homeModules.nushell =
    let
      cs = self.theme.colors;
      colorscheme-dash = builtins.replaceStrings [ "_" ] [ "-" ] self.theme.colorscheme;
    in
    {
      xdg.configFile."nushell/env.nu".text =
        # nu
        ''
          $env.PATH = $env.PATH
            | split row (char esep)
            | append '/usr/local/bin'
            | append ($env.HOME | path join ".elan" "bin")
            | prepend ($env.HOME | path join ".cargo" "bin")
            | prepend ($env.HOME | path join ".local" "bin")
            | uniq
        '';
      xdg.configFile."nushell/style.nu".text =
        # nu
        ''
          def prompt_decorator [
            font_color: string
            bg_color: string
            symbol: string
            with_starship?: bool = true
          ] {
            let bg1 = if $with_starship { '${cs.white}' } else $bg_color
            let fg = {fg: $bg_color}
            let bg = {fg: $font_color bg: $bg_color}
            let startship_leading = if $with_starship { $"(ansi --escape {fg: $bg_color bg: $bg1})" } else ""
            $"($startship_leading)(ansi --escape $bg)($symbol)(ansi reset)(ansi --escape $fg)(ansi reset) "
          }

          let dev_tag = if (
            $nu.current-exe == (which nu).path.0
          ) { "" } else ' '
          $env.PROMPT_INDICATOR = {|| "> " }
          $env.PROMPT_INDICATOR_VI_INSERT = {|| prompt_decorator "${cs.black}" "${cs.light_green}" ($dev_tag + "󰏫") }
          $env.PROMPT_INDICATOR_VI_NORMAL = {|| prompt_decorator "${cs.black}" "${cs.yellow}" ($dev_tag + "") }
          $env.LS_COLORS = (vivid generate ${colorscheme-dash} | str trim)
          $env.FZF_DEFAULT_OPTS = ($env.FZF_DEFAULT_OPTS? | default "") + $" --prompt '(prompt_decorator '${cs.black}' '${cs.green}' '▓▒░ ' false)'"
          const themes_config_file = "themes/${self.theme.colorscheme}.nu"
        '';
    };
}
