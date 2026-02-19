{ lib, self, ... }:
{
  flake.darwinModules.homebrew = {
    homebrew.brews = [ "nushell" ];
  };

  flake.homeModules.nushell =
    { config, ... }:
    let
      cs = self.theme.colors;
      pg = config.programs;
      colorscheme-dash = builtins.replaceStrings [ "_" ] [ "-" ] self.theme.colorscheme;
      carapace_config =
        # nu
        ''
          use fzf.nu [
            carapace_by_fzf
            complete_line_by_fzf
            update_manpage_cache
            atuin_menus_func
          ]
          $env.config.completions.external.completer = {|span| carapace_by_fzf $span }
          $env.config.keybindings ++= [
            {
              name: fuzzy_complete
              modifier: control
              keycode: char_t
              mode: [emacs vi_normal vi_insert]
              event: {
                send: executehostcommand
                cmd: complete_line_by_fzf
              }
            }
          ]

          $env.config.menus ++= [
            {
              name: my_history_menu
              only_buffer_difference: false
              marker: ``
              type: {layout: ide}
              style: {}
              source: (
                atuin_menus_func
                (
                  prompt_decorator
                  $extra_colors.prompt_symbol_color
                  'light_blue'
                  '▓▒░ Ctrl-d to del '
                  false
                )
              )
            }
          ]
        '';
      completer_config =
        if pg.carapace.enable && pg.atuin.enable && pg.fzf.enable then carapace_config else "";
      vivid_config =
        if pg.vivid.enable then "$env.LS_COLORS = (vivid generate ${colorscheme-dash} | str trim)" else "";
    in
    {
      programs.nushell = {
        enable = true;
        # installed via homebrew
        package = null;
        shellAliases = pg.zsh.shellAliases // {
          less = "less -R";
        };
        settings = {
          history = {
            file_format = "sqlite";
            max_size = 2000;
          };
          table = {
            header_on_separator = true;
            index_mode = "auto";
          };
          cursor_shape = {
            emacs = "line";
            vi_insert = "line";
            vi_normal = "block";
          };
          edit_mode = "vi";
          buffer_editor = "nvim";
          highlight_resolved_externals = true;
          show_banner = false;
          render_right_prompt_on_last_line = true;
        };
        envFile.text =
          # nu
          ''
            $env.PATH = $env.PATH
              | split row (char esep)
              | append '/usr/local/bin'
              | append ($env.HOME | path join ".elan" "bin")
              | prepend ($env.HOME | path join ".cargo" "bin")
              | prepend ($env.HOME | path join ".local" "bin")
              | uniq

            $env.CARAPACE_LENIENT = 1
            $env.CARAPACE_BRIDGES = 'zsh'
            $env.MANPAGER = "col -bx | bat -l man -p"
            $env.MANPAGECACHE = ($nu.default-config-dir | path join 'mancache.txt')
            $env.RUST_BACKTRACE = 1
          '';
        configFile.text =
          # nu
          ''
            source style.nu
            source $themes_config_file

            $env.config.menus ++= [
              # Configuration for default nushell menus
              # Note the lack of source parameter
              {
                name: completion_menu
                only_buffer_difference: false
                marker: (prompt_decorator $extra_colors.prompt_symbol_color "yellow" "")
                type: {
                  layout: columnar
                  columns: 4
                  col_width: 20 # Optional value. If missing all the screen width is used to calculate column width
                  col_padding: 2
                }
                style: {
                  text: $extra_colors.menu_text_color
                  selected_text: {attr: r}
                  description_text: yellow
                  match_text: {attr: u}
                  selected_match_text: {attr: ur}
                }
              }
              {
                name: history_menu
                only_buffer_difference: false
                marker: (prompt_decorator $extra_colors.prompt_symbol_color "light_blue" "")
                type: {
                  layout: list
                  page_size: 30
                }
                style: {
                  text: $extra_colors.menu_text_color
                  selected_text: light_blue_reverse
                  description_text: yellow
                }
              }
            ]

            $env.config.keybindings ++= [
              {
                name: history_menu
                modifier: control
                keycode: char_h
                mode: [emacs vi_insert vi_normal]
                event: {send: menu name: my_history_menu}
                # event: {send: menu name: ide_completion_menu}
              }
              {
                name: vicmd_history_menu
                modifier: shift
                keycode: char_k
                mode: vi_normal
                event: {send: menu name: my_history_menu}
              }
              {
                name: cut_line_to_end
                modifier: control
                keycode: char_k
                mode: [emacs vi_insert]
                event: {edit: cuttoend}
              }
              {
                name: cut_line_from_start
                modifier: control
                keycode: char_u
                mode: [emacs vi_insert]
                event: {edit: cutfromstart}
              }
            ]

            ${completer_config}

            use scripts/extractor.nu extract
            use auto-pair.nu *
            set auto_pair_keybindings
            use matchit.nu *
            set matchit_keybinding
          '';
      };

      xdg.configFile."nushell/style.nu".text =
        # nu
        ''
          def prompt_decorator [
            font_color: string
            bg_color: string
            symbol: string
            with_starship?: bool = ${lib.boolToString pg.starship.enable}
          ] {
            let bg1 = if $with_starship { '${cs.white}' } else $bg_color
            let fg = {fg: $bg_color}
            let bg = {fg: $font_color bg: $bg_color}
            let startship_leading = if $with_starship { $"(ansi --escape {fg: $bg_color bg: $bg1})" } else ""
            $"($startship_leading)(ansi --escape $bg)($symbol)(ansi reset)(ansi --escape $fg)(ansi reset) "
          }

          let dev_tag = if (
            $nu.current-exe == (which nu).path.0
          ) { "" } else ' '
          $env.PROMPT_INDICATOR = {|| "> " }
          $env.PROMPT_INDICATOR_VI_INSERT = {|| prompt_decorator "${cs.black}" "${cs.light_green}" ($dev_tag + "󰏫") }
          $env.PROMPT_INDICATOR_VI_NORMAL = {|| prompt_decorator "${cs.black}" "${cs.yellow}" ($dev_tag + "") }
          ${vivid_config}
          $env.FZF_DEFAULT_OPTS = ($env.FZF_DEFAULT_OPTS? | default "") + $" --prompt '(prompt_decorator '${cs.black}' '${cs.green}' '▓▒░ ' false)'"
          const themes_config_file = "themes/${self.theme.colorscheme}.nu"
        '';
    };
}
