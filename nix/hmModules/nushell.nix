{ colorscheme, ... }:
let
  cs = import ../colorscheme.nix { inherit colorscheme; };
  colorscheme-dash = builtins.replaceStrings [ "_" ] [ "-" ] colorscheme;
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
        let bg1 = if $with_starship {'${cs.white}'} else $bg_color
        let fg = { fg: $bg_color }
        let bg = { fg: $font_color bg: $bg_color }
        let startship_leading = if $with_starship {$"(ansi --escape { fg: $bg_color bg: $bg1 })"} else ""
        $"($startship_leading)(ansi --escape $bg)($symbol)(ansi reset)(ansi --escape $fg)(ansi reset) "
      }

      let dev_tag = if $nu.current-exe == $env.SHELL {""} else ' '
      $env.PROMPT_INDICATOR = {|| "> "}
      $env.PROMPT_INDICATOR_VI_INSERT = {|| prompt_decorator "${cs.black}" "${cs.light_green}" ($dev_tag + "󰏫")}
      $env.PROMPT_INDICATOR_VI_NORMAL = {|| prompt_decorator "${cs.black}" "${cs.yellow}" ($dev_tag + "")}
      $env.LS_COLORS = (vivid generate ${colorscheme-dash} | str trim)
      $env.FZF_DEFAULT_OPTS = (
        "--exit-0 --layout reverse --header-first --tmux center,80%,60% "
        + "--pointer ▶ --marker 󰍕 --preview-window right,65% "
        + "--bind 'bs:backward-delete-char/eof,tab:accept-or-print-query,ctrl-t:toggle+down,ctrl-s:change-multi' "
        + $"--prompt '(prompt_decorator '${cs.black}' '${cs.green}' '▓▒░ ' false)' "
        + "--color=fg:${cs.white},hl:${cs.red} "
        + "--color=fg+:${cs.cyan},bg+:${cs.black},hl+:${cs.red} "
        + "--color=info:${cs.blue},prompt:${cs.yellow},pointer:${cs.red} "
        + "--color=marker:${cs.white},spinner:${cs.green},header:${cs.white}"
      )
    '';
}
