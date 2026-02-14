{
  lib,
  inputs,
  self,
  ...
}:
{
  flake.darwinModules.homebrew = {
    imports = [
      inputs.nix-homebrew.darwinModules.nix-homebrew
    ];

    # nix-homebrew configuration
    nix-homebrew = {
      enable = true;
      user = self.identity.username;
      enableRosetta = false;
      autoMigrate = true;
      # mutableTaps = false; # functional homebrew
    };

    homebrew = {
      enable = true;
      onActivation.cleanup = "zap";
      onActivation.autoUpdate = false;
      onActivation.upgrade = false;
      brews = [
        "neovim"
        "node"
        "nushell"
        "mole"
        "gemini-cli"
        "openclaw-cli"
      ];
      casks = [
        "balenaetcher"
        "betterdisplay"
        "blender"
        "discord"
        "dropbox"
        "ghostty"
        "google-chrome"
        "karabiner-elements"
        "kicad"
        "macs-fan-control"
        "openscad"
        "popclip"
        "raycast"
        "steam"
        "yam-display"
        "zed"
      ];
    };
  };

  flake.homeModules.ghostty =
    { pkgs, ... }:
    {
      xdg.configFile."ghostty/config".text = ''
        initial-command = ${lib.getExe pkgs.tmux} new -A -s dev
        font-family = "${self.font.monofont}"
        font-size = 15
        theme = "${builtins.split "_" self.theme.colorscheme |> builtins.head}"
        background-opacity = 0.8
        background = #000000
        macos-titlebar-style = hidden
        custom-shader = shaders/cursor_blaze.glsl
        quit-after-last-window-closed = true
      '';
    };

  flake.homeModules.nushell =
    let
      cs = self.theme.colors;
      colorscheme-dash = builtins.replaceStrings [ "_" ] [ "-" ] self.theme.colorscheme;
    in
    {
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
          $env.FZF_DEFAULT_OPTS = (
            "--layout reverse --header-first --tmux center,80%,60% "
            + "--pointer ▶ --marker 󰍕 --preview-window right,65% "
            + "--bind 'bs:backward-delete-char/eof,tab:accept-or-print-query,ctrl-t:toggle+down,ctrl-s:change-multi' "
            + $"--prompt '(prompt_decorator '${cs.black}' '${cs.green}' '▓▒░ ' false)' "
            + "--color=fg:${cs.white},hl:${cs.red} "
            + "--color=fg+:${cs.cyan},bg+:${cs.black},hl+:${cs.red} "
            + "--color=info:${cs.blue},prompt:${cs.yellow},pointer:${cs.red} "
            + "--color=marker:${cs.white},spinner:${cs.green},header:${cs.white}"
          )
          const themes_config_file = "themes/${self.theme.colorscheme}.nu"
        '';
    };
}
