{ self, ... }:
{
  flake.homeModules.tmux =
    { pkgs, ... }:
    {
      programs.tmux = {
        enable = true;
        prefix = "C-q";
        keyMode = "vi";
        # for neovim autoread on file change
        focusEvents = true;
        shell = "/opt/homebrew/bin/nu";
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
            plugin = tmuxPlugins.catppuccin;
            extraConfig = ''
              # Configure the catppuccin plugin
              set -g @catppuccin_flavor "mocha"
              set -g @catppuccin_status_background "none"

              # status left style
              set -g status-left-length 100
              set -g status-left ""
              set -ga status-left "#{?client_prefix,#{#[bg=#{@thm_red},fg=#{@thm_mantle},bold]  #S },#{#[bg=#{@thm_mantle},fg=#{@thm_green}]  #S }}"
              set -ga status-left "#[bg=#{@thm_mantle},fg=#{@thm_overlay_0},none]│"
              set -ga status-left "#[bg=#{@thm_mantle},fg=#{@thm_maroon}]  #{pane_current_command} "
              set -ga status-left "#[bg=#{@thm_mantle},fg=#{@thm_overlay_0},none]│"
              set -ga status-left "#[bg=#{@thm_mantle},fg=#{@thm_blue}]  #{=/-32/...:#{s|$USER|~|:#{b:pane_current_path}}} "

              # status right style
              set -g status-right-length 100
              set -g status-right ""
              set -ga status-right "#[bg=#{@thm_mantle},fg=#{@thm_blue}] 󰭦 %Y-%m-%d 󰅐 %H:%M "

              # window style
              set -g status-justify 'absolute-centre'

              set -g @catppuccin_window_status_style 'custom'
              set -g @catppuccin_window_number ""
              set -g @catppuccin_window_text "#[fg=#{@thm_rosewater},bg=#{@thm_mantle}] #W"
              set -g @catppuccin_window_current_number ""
              set -g @catppuccin_window_current_text "#[fg=#{@thm_mantle},bg=#{@thm_green}] #W"
              set -g @catppuccin_window_flags "icon" # none, icon, or text
              set -g @catppuccin_window_flags_icon_last " " # -
              set -g @catppuccin_window_flags_icon_current " " # *
              set -g @catppuccin_window_flags_icon_zoom " " # Z
              set -g @catppuccin_window_flags_icon_mark " " # M
              set -g @catppuccin_window_flags_icon_silent " " # ~
              set -g @catppuccin_window_flags_icon_activity " " # #
              set -g @catppuccin_window_flags_icon_bell " " # !
            '';
          }
        ];
        extraConfig = ''
          set-env -g XDG_CONFIG_HOME "/Users/${self.identity.username}/.config"
          set-option -g status-position top
          set -g set-titles on
          set -g set-titles-string '#I:#W'
          bind ^k resizep -U 10
          bind ^j resizep -D 10
          bind ^h resizep -L 10
          bind ^l resizep -R 10

          # Clickable links
          set -ga terminal-features ",*:hyperlinks"
        '';
      };
    };
}
