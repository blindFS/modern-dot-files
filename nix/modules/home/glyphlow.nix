{ inputs, self, ... }:
{
  flake.homeModules.glyphlow =
    { osConfig, ... }:
    let
      nushell_exe = self.nushell_exe osConfig;
    in
    {
      imports = [
        inputs.glyphlow.homeManagerModules.glyphlow
      ];

      programs.glyphlow = {
        enable = true;
        settings = {
          theme = {
            menu_font = "${self.font.monofont}:18";
          };
          visibility_checking_level = "Loose";
          hide_scrolling_menu = true;
          colored_frame_min_size = 100;
          element_min_width = 15;
          element_min_height = 15;
          ocr_languages = [
            "zh-Hans"
            "ja-JP"
            "en-US"
          ];
          dictionaries = [
            "牛津英汉汉英词典"
            "New Oxford American Dictionary"
          ];
          editor = {
            display = " Editor";
            key = "V";
            command = "open";
            args = [
              "-a"
              "Zed"
              "{glyphlow_temp_file}"
            ];
          };
          text_actions = [
            {
              display = "󰊭 Google Search";
              key = "G";
              command = nushell_exe;
              args = [
                "-c"
                "r#'{glyphlow_text}'# | url encode | ^open $'https://google.com/search?q=($in)'"
              ];
            }
            {
              display = "󰖬 Wikipedia Search";
              key = "W";
              command = nushell_exe;
              args = [
                "-c"
                "r#'{glyphlow_text}'# | url encode | ^open $'https://en.wikipedia.org/wiki/Special:Search/($in)'"
              ];
            }
            {
              display = "󰊿 Goolge Translate -> zh_cn";
              key = "T";
              command = nushell_exe;
              args = [
                "-c"
                "r#'{glyphlow_text}'# | url encode | ^open $'https://translate.google.com/?sl=auto&tl=zh_cn&text=($in)&op=translate'"
              ];
            }
          ];
          workflows = [

            {
              display = " ProofRead";
              key = "AO";
              starting_role = "TextField";
              actions = [
                "Focus"
                "SelectAll"
                "ShowMenu"
                { Sleep = 150; }
                {
                  SearchFor = {
                    role = "MenuItem";
                    title = "Proofread";
                  };
                }
                "Press"
              ];
            }
            {
              display = " Rewrite";
              key = "AR";
              starting_role = "TextField";
              actions = [
                "Focus"
                "SelectAll"
                "ShowMenu"
                { Sleep = 150; }
                {
                  SearchFor = {
                    role = "MenuItem";
                    title = "Rewrite";
                  };
                }
                "Press"
              ];
            }
            {
              display = "⮺ Copy";
              key = "C";
              starting_role = "Image";
              actions = [
                "ShowMenu"
                { Sleep = 150; }
                {
                  SearchFor = {
                    role = "MenuItem";
                    title = "Copy Image";
                  };
                }
                "Press"
              ];
            }
            {
              display = " Copy Link";
              key = "L";
              starting_role = "Image";
              actions = [
                "ShowMenu"
                { Sleep = 150; }
                {
                  SearchFor = {
                    role = "MenuItem";
                    title = "Copy Image Address";
                  };
                }
                "Press"
              ];
            }
            {
              display = "󰋱 Hover";
              key = "H";
              starting_role = "Generic";
              actions = [ "Hover" ];
            }
            {
              display = "󰳽 Press [Left Click]";
              key = "[";
              starting_role = "Generic";
              actions = [ "Click" ];
            }
            {
              display = " Menu [Right Click]";
              key = "]";
              starting_role = "Generic";
              actions = [
                "ShowMenu"
                { Sleep = 150; }
                {
                  SearchFor = {
                    role = "MenuItem";
                  };
                }
                "Press"
              ];
            }
            {
              display = " Debug";
              key = "ZD";
              starting_role = "Generic";
              actions = [ "Debug" ];
            }
            {
              display = " Select Parent";
              key = "ZP";
              starting_role = "Generic";
              actions = [
                "GoParent"
                "GlyphlowMenu"
              ];
            }
            {
              display = "󱄊 Clear System Notification";
              key = "NC";
              starting_role = "Any";
              valid_app_ids = [ "com.apple.notificationcenterui" ];
              actions = [
                {
                  SearchFor = {
                    role = "Group";
                    subrole = "Banner";
                  };
                }
                "Hover"
                {
                  SearchFor = {
                    role = "Button";
                    description = "Close";
                  };
                }
                "Press"
              ];
            }
          ];
        };
      };
    };
}
