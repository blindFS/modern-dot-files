{ self, ... }:
{
  flake.darwinModules.preferrence =
    { pkgs, ... }:
    {
      # # Disable useless memory hog services
      # # HACK: use `keyboard` as name BC https://github.com/nix-darwin/nix-darwin/issues/1447
      # system.activationScripts.keyboard.text = ''
      #   mdutil -i off
      #
      #   MYUID=$(id -u ${self.identity.username})
      #   launchctl disable "gui/$MYUID/com.apple.applespell"
      #   launchctl disable "gui/$MYUID/com.apple.mediaanalysisd"
      #   launchctl disable "gui/$MYUID/com.apple.suggestd"
      #   launchctl disable "gui/$MYUID/com.apple.contactsd"
      #   launchctl disable "gui/$MYUID/com.apple.corespotlightd"
      #   launchctl disable "gui/$MYUID/com.apple.spotlightknowledged.updater"
      #   launchctl disable "gui/$MYUID/com.apple.photolibraryd"
      #   launchctl disable "gui/$MYUID/com.apple.stickersd"
      # '';

      environment.systemPackages = [
        # Useful cli tool to check system plist values
        pkgs.plistwatch
      ];

      power.sleep.display = "never";
      system.keyboard = {
        enableKeyMapping = true;
        swapLeftCommandAndLeftAlt = true;
      };
      system.defaults = {
        dock = {
          autohide = true;
          orientation = "left";
        };
        finder = {
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          QuitMenuItem = true;
          ShowPathbar = true;
          ShowStatusBar = true;
        };
        NSGlobalDomain = {
          AppleInterfaceStyle = "Dark";
          AppleMetricUnits = 1;
          AppleShowScrollBars = "WhenScrolling";
          _HIHideMenuBar = true;
          NSAutomaticWindowAnimationsEnabled = false;
          # keyboard
          KeyRepeat = 1;
          "com.apple.keyboard.fnState" = true;
          NSAutomaticSpellingCorrectionEnabled = false;
          NSAutomaticCapitalizationEnabled = false;
        };
        WindowManager = {
          AppWindowGroupingBehavior = false;
          EnableStandardClickToShowDesktop = false;
        };
        CustomUserPreferences = {
          # indie input method per-app
          "com.apple.HIToolbox" = {
            AppleEnabledInputSources = [
              {
                InputSourceKind = "Keyboard Layout";
                "KeyboardLayout ID" = 252;
                "KeyboardLayout Name" = "ABC";
              }
              {
                InputSourceKind = "Keyboard Input Method";
                "Bundle ID" = "com.apple.inputmethod.SCIM";
              }
              {
                InputSourceKind = "Input Mode";
                "Bundle ID" = "com.apple.inputmethod.SCIM";
                "Input Mode" = "com.apple.inputmethod.SCIM.ITABC";
              }
            ];
            AppleGlobalTextInputProperties.TextInputGlobalPropertyPerContextInput = 1;
          };
        };
      };
    };

  flake.homeModules.config =
    { ... }:
    {
      home.file."Library/KeyBindings/DefaultKeyBinding.dict".text = ''
        {
            "^u" = "deleteToBeginningOfLine:";
            "^w" = "deleteWordBackward:";
        }
      '';
    };
}
