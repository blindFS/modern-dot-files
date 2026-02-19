{ lib, self, ... }:
let
  cs = self.theme.colors;
  pw = {
    left = "";
    right = "";
  };
  fg-bg = fg: bg: "fg:${fg} bg:${bg}";
  txt-fg = txt: fg: "[${txt}](fg:${fg})";
  txt-fg-bg =
    txt: fg: bg:
    "[${txt}](${fg-bg fg bg})";
  dev-env = sym: {
    format = "${txt-fg pw.left cs.dark_grey}${
      txt-fg-bg "${sym} ($version)" cs.blue cs.dark_grey
    }${txt-fg pw.right cs.dark_grey}";
  };
in
{
  flake.homeModules.starship = {
    programs.starship = {
      enable = true;

      settings = {
        add_newline = false;
        fill.symbol = " ";

        format = lib.concatStrings [
          "$cmd_duration"
          "$directory"
          "\n"
          "$character"
        ];
        right_format = lib.concatStrings [
          "$env_var"
          "$git_branch"
          "$git_status"
          "$nodejs"
          "$rust"
          "$golang"
          "$python"
        ];

        directory = {
          style = fg-bg cs.black cs.blue;
          format = "${txt-fg "░▒▓" cs.blue}[ $path ]($style)${txt-fg pw.right cs.blue}";
          truncation_length = 3;
          truncation_symbol = " 󰇘/";
          home_symbol = "";
        };

        directory.substitutions = {
          "Documents" = "󰈙";
          "Downloads" = "";
          "Music" = "";
          "Pictures" = "";
        };

        character = {
          success_symbol = txt-fg-bg "" cs.black cs.white;
          error_symbol = txt-fg-bg "󰊠" cs.warn cs.white;
          vimcmd_symbol = txt-fg-bg "" cs.black cs.white;
          format = "${txt-fg "▓" cs.white}[ $symbol ](bg:${cs.white})";
        };

        cmd_duration.min_time = 20000;
        cmd_duration.format = txt-fg-bg "  $duration " cs.yellow cs.black;

        env_var.proxy.variable = "http_proxy";
        env_var.proxy.format = txt-fg "🌐" cs.dark_grey;

        git_branch.format = "${txt-fg pw.left cs.grey}${txt-fg-bg "  $branch " cs.blue cs.grey}";
        git_status.format = "${
          txt-fg-bg "($all_status $ahead_behind )" cs.blue cs.grey
        }${txt-fg pw.right cs.grey}";

        nodejs = dev-env "";
        rust = dev-env "";
        golang = dev-env "";
        python = dev-env "";

        time = {
          disabled = false;
          time_format = "%R";
          format = txt-fg-bg "  $time " cs.white cs.black;
        };
      };
    };
  };
}
