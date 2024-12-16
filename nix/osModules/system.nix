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
      "AppleGlobalTextInputProperties" = {
        "TextInputGlobalPropertyPerContextInput" = 1;
      };
    };
  };
}
