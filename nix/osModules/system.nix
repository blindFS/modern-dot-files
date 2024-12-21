{
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
}
