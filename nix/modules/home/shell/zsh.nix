{ lib, ... }:
let
  zshConfigEarlyInit =
    lib.mkOrder 500
      # sh
      "zmodload zsh/zprof";
  zshConfig =
    lib.mkOrder 1000
      # sh
      ''
        bindkey -M vicmd 'gh' vi-beginning-of-line
        bindkey -M vicmd 'gl' vi-end-of-line
        bindkey -M vicmd 'k' history-substring-search-up
        bindkey -M vicmd 'j' history-substring-search-down
        bindkey -M vicmd 'u'  undo
        bindkey -M vicmd '^R' redo
        bindkey -M viins '^P' history-substring-search-up
        bindkey -M viins '^N' history-substring-search-down
        bindkey -M viins '^K' kill-line
        bindkey -M viins '^B' backward-word
        bindkey -M viins '^F' forward-word
        bindkey -M viins '^A' beginning-of-line
        bindkey -M viins '^E' end-of-line

        zmodload zsh/complist
        bindkey -M menuselect 'h' vi-backward-char
        bindkey -M menuselect 'j' vi-down-line-or-history
        bindkey -M menuselect 'k' vi-up-line-or-history
        bindkey -M menuselect 'l' vi-forward-char

        zstyle ':completion:*:*:*:*:*'      menu             select
        zstyle ':completion:*:options'      description      'yes'
        zstyle ':completion:*:options'      auto-description '%d'
        zstyle ':completion:*:descriptions' format           $' \e[30;42m 󰵅 %d \e[0m\e[32m\e[0m'
        zstyle ':completion:*:messages'     format           $' \e[30;45m 󰍡 %d \e[0m\e[35m\e[0m'
        zstyle ':completion:*:warnings'     format           $' \e[30;41m  \e[0m\e[31m\e[0m'
      '';
in
{
  flake.homeModules.zsh =
    { ... }:
    {
      programs.zsh = {
        enable = true;
        defaultKeymap = "viins";

        # plugins
        historySubstringSearch.enable = true;
        autosuggestion = {
          enable = true;
          strategy = [
            "history"
            "completion"
          ];
        };
        syntaxHighlighting = {
          enable = true;
          highlighters = [
            "brackets"
            "cursor"
          ];
        };
        antidote = {
          enable = true;
          plugins = [
            "hlissner/zsh-autopair"
            "Aloxaf/fzf-tab"
          ];
        };

        initContent = lib.mkMerge [
          zshConfigEarlyInit
          zshConfig
        ];
        sessionVariables = {
          LANG = "en_US.UTF-8";
          LC_ALL = "en_US.UTF-8";
        };
        shellAliases = {
          boc = "brew outdated --cask --greedy";
          ll = "eza --tree -L 1 -l -a";
          vim = "nvim";
          zi = "__zoxide_zi";
        };
      };
    };
}
