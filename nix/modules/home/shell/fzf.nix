{ self, ... }:
let
  cs = self.theme.colors;
in
{
  flake.homeModules.fzf =
    { ... }:
    {
      programs.fzf = {
        enable = true;
        defaultCommand = "fd --hidden --strip-cwd-prefix --exclude .git --exclude .cache --max-depth 9";
        defaultOptions = [
          "--layout reverse"
          "--header-first"
          "--tmux center,80%,60%"
          "--pointer ▶"
          "--marker 󰍕"
          "--preview-window right,65%"
          "--bind 'bs:backward-delete-char/eof,tab:accept-or-print-query,ctrl-t:toggle+down,ctrl-s:change-multi'"
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
