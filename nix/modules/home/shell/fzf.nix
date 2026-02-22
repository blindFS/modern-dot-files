{ lib, self, ... }:
let
  cs = self.theme.colors;
  keybindings = {
    "bs" = "backward-delete-char/eof";
    "tab" = "accept-or-print-query";
    "ctrl-t" = "toggle+down";
    "ctrl-s" = "change-multi";
  };
  kbd_opts = lib.mapAttrsToList (k: v: "${k}:${v}") keybindings |> lib.concatStringsSep ",";
  ansi_black_green = "[30;42m";
  ansi_reset = "[0m";
  ansi_green = "[32m";
in
{
  flake.homeModules.fzf =
    { config, ... }:
    let
      fancy = config.programs.starship.enable;
      prefix = lib.optionalString fancy config.starship.prefix;
      arrow = lib.optionalString fancy config.starship.arrow;
    in
    {
      programs.fd = {
        enable = true;
        hidden = true;
        ignores = [
          ".git"
          ".cache"
          "*.bak"
        ];
        extraOptions = [
          "--strip-cwd-prefix"
          "--max-depth 9"
        ];
      };

      programs.fzf = {
        enable = true;
        defaultCommand = "fd";
        defaultOptions = [
          "--layout reverse"
          "--header-first"
          "--tmux center,80%,60%"
          "--pointer ▶"
          "--marker 󰍕"
          "--preview-window right,65%"
          "--prompt '${ansi_black_green}${prefix} ${ansi_reset}${ansi_green}${arrow}${ansi_reset} '"
          "--bind '${kbd_opts}'"
        ];
        colors = {
          fg = cs.white;
          hl = cs.red;
          "fg+" = cs.cyan;
          "bg+" = cs.black;
          "hl+" = cs.purple;
          info = cs.blue;
          prompt = cs.yellow;
          pointer = cs.red;
          marker = cs.light_blue;
          spinner = cs.green;
          header = cs.white;
        };
      };
    };
}
