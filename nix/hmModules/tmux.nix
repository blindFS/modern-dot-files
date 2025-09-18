{
  pkgs,
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
        plugin = tmuxPlugins.tokyo-night-tmux;
        extraConfig = ''
          set -g @tokyo-night-tmux_transparent 1
          set -g @tokyo-night-tmux_window_id_style digital
          set -g @tokyo-night-tmux_pane_id_style hsquare
          set -g @tokyo-night-tmux_zoom_id_style dsquare
          set -g @tokyo-night-tmux_show_datetime 0

          # Icon styles
          set -g @tokyo-night-tmux_terminal_icon 
          set -g @tokyo-night-tmux_active_terminal_icon 

          # No extra spaces between icons
          set -g @tokyo-night-tmux_window_tidy_icons 0

          # Widgets
          set -g @tokyo-night-tmux_show_path 1
          set -g @tokyo-night-tmux_path_format relative
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
