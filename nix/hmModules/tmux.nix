{
  pkgs,
  inputs,
  username,
  arch,
  ...
}:
{
  programs.tmux = {
    enable = true;
    prefix = "C-q";
    keyMode = "vi";
    # for neovim autoread on file change
    focusEvents = true;
    shell = "${pkgs.nushell}/bin/nu";
    terminal = "xterm-256color";
    baseIndex = 1;
    aggressiveResize = true;
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.pain-control;
        extraConfig = ''
          bind -Tcopy-mode-vi v send -X begin-selection
          bind -Tcopy-mode-vi y send -X copy-pipe "xclip -selection clipboard"
        '';
      }
      {
        plugin = inputs.tmux-sessionx.packages."${arch}".default;
        extraConfig = ''
          set -g @sessionx-bind 'o'
          set -g @sessionx-zoxide-mode 'on'
          set -g @sessionx-custom-paths '/Users/${username}/Workspace'
          set -g @sessionx-custom-paths-subdirectories 'false'
          set -g @sessionx-fzf-builtin-tmux 'on'
          set -g @sessionx-window-mode 'on'
          set -g @sessionx-tree-mode 'off'
          set -g @sessionx-ls-command 'eza --tree -L 3 --color=always'
          set -g @sessionx-preview-location 'right'
          set -g @sessionx-preview-ratio '55%'
          set -g @sessionx-additional-options "--color pointer:9,spinner:92,marker:46"
        '';
      }
      {
        # plugin = tmuxPlugins.catppuccin;
        plugin = tmuxPlugins.mkTmuxPlugin {
          pluginName = "catppuccin";
          version = "unstable";
          src = inputs.tmux-catppuccin;
        };
        extraConfig = ''
          set -g @catppuccin_flavor "mocha"
          # set -g @catppuccin_window_status_style "basic"
          set -g @catppuccin_window_status_style ""
          set -g @catppuccin_window_text " #W"
          set -g @catppuccin_window_current_text " #W"
          set -g @catppuccin_window_flags "icon"
          set -g @catppuccin_window_flags_icon_last " 󰖰" # -
          set -g @catppuccin_window_flags_icon_current " 󰖯" # *
          set -g @catppuccin_window_flags_icon_zoom " 󰁌" # Z
          set -g @catppuccin_window_flags_icon_mark " 󰃀" # M
          set -g @catppuccin_window_flags_icon_silent " 󰂛" # ~
          set -g @catppuccin_window_flags_icon_activity " 󱅫" # #
          set -g @catppuccin_window_flags_icon_bell " 󰂞" # !
          set -g @catppuccin_status_background "none"
          set -g @catppuccin_status_connect_separator "yes"
          set -g status-left "#{E:@catppuccin_status_session}"
          set -g status-right "#{E:@catppuccin_status_user}"
          set -ag status-right "#{E:@catppuccin_status_directory}"
        '';
      }
    ];
    extraConfig = ''
      set-option -g status-position top
      set -g set-titles on
      set -g set-titles-string '#I:#W'
      bind ^k resizep -U 10
      bind ^j resizep -D 10
      bind ^h resizep -L 10
      bind ^l resizep -R 10
    '';
  };
}
