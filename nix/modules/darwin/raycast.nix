{
  flake.darwinModules.homebrew.homebrew.casks = [ "raycast" ];

  flake.darwinModules.raycast =
    { ... }:
    {
      system.defaults.CustomUserPreferences."com.raycast.macos" = {
        enforcedInputSourceIDOnOpen = "com.apple.keylayout.ABC";
        raycastGlobalHotkey = "Command-15";
        "NSStatusItem VisibleCC raycastIcon" = 0;
      };
    };
}
