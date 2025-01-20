{
  pkgs,
  inputs,
  username,
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
    terminal = "xterm-ghostty";
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
      set-env -g XDG_CONFIG_HOME "/Users/${username}/.config"
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
