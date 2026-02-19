{ lib, ... }:
let
  zshConfigEarlyInit =
    lib.mkOrder 500
      # sh
      ''
        zmodload zsh/zprof
        zmodload zsh/complist

        ZINIT_HOME="$HOME/.zinit/zinit.git"
        [ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
        [ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
        source "$ZINIT_HOME/zinit.zsh"

        zinit light zsh-users/zsh-history-substring-search
        zinit snippet OMZP::extract/extract.plugin.zsh

        zinit wait lucid for \
         atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
            zdharma-continuum/fast-syntax-highlighting \
         blockf \
            zsh-users/zsh-completions \
         atload"!_zsh_autosuggest_start" \
            zsh-users/zsh-autosuggestions
        export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

        zinit ice wait'0c' lucid atinit'zpcompinit;zpcdreplay'
        zinit light hlissner/zsh-autopair

        zinit ice depth=1
        zinit light jeffreytse/zsh-vi-mode

        zinit ice wait'1' lucid
        zinit light Aloxaf/fzf-tab
      '';
  zshConfig =
    lib.mkOrder 1000
      # sh
      ''
        bindkey -v
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
