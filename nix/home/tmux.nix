{ pkgs, username, ... }:
{
  enable = true;
  prefix = "C-q";
  keyMode = "vi";
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
      plugin = tmuxPlugins.mkTmuxPlugin {
        pluginName = "sessionx";
        version = "unstable";
        src = pkgs.fetchFromGitHub {
          owner = "omerxx";
          repo = "tmux-sessionx";
          rev = "main";
          sha256 = "sha256-5f2lADOgCSSfFrPy9uiTomtjSZPkEAMEDu4/TdDYXlk=";
        };
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postPatch = ''
          substituteInPlace sessionx.tmux \
            --replace-fail "\$CURRENT_DIR/scripts/sessionx.sh" "$out/share/tmux-plugins/sessionx/scripts/sessionx.sh"
          substituteInPlace scripts/sessionx.sh \
            --replace-fail "/tmux-sessionx/scripts/preview.sh" "$out/share/tmux-plugins/sessionx/scripts/preview.sh"
          substituteInPlace scripts/sessionx.sh \
            --replace-fail "/tmux-sessionx/scripts/reload_sessions.sh" "$out/share/tmux-plugins/sessionx/scripts/reload_sessions.sh"
        '';
        postInstall = ''
          chmod +x $target/scripts/sessionx.sh
          wrapProgram $target/scripts/sessionx.sh \
            --prefix PATH : ${
              with pkgs;
              lib.makeBinPath [
                zoxide
                fzf
                gnugrep
                gnused
                coreutils
              ]
            }
          chmod +x $target/scripts/preview.sh
          wrapProgram $target/scripts/preview.sh \
            --prefix PATH : ${
              with pkgs;
              lib.makeBinPath [
                coreutils
                gnugrep
                gnused
              ]
            }
          chmod +x $target/scripts/reload_sessions.sh
          wrapProgram $target/scripts/reload_sessions.sh \
            --prefix PATH : ${
              with pkgs;
              lib.makeBinPath [
                coreutils
                gnugrep
                gnused
              ]
            }
        '';
      };
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
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "tmux";
          rev = "main";
          sha256 = "sha256-9+SpgO2Co38I0XnEbRd7TSYamWZNjcVPw6RWJIHM+4c=";
        };
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
}
