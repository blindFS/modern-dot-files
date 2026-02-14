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
              set -g window-status-separator '|'
              set -g status-justify 'absolute-centre'
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
