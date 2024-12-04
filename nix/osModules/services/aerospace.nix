{ pkgs, ... }:
let
  trigger = event: variables: "${pkgs.sketchybar}/bin/sketchybar --trigger ${event} ${variables}";
  aeroswitch = mode: [
    "mode ${mode}"
    ("exec-and-forget" + trigger "aerospace_mode_change" "MODE=${mode}")
  ];
  move-and-focus = space: [
    "move-node-to-workspace ${space}"
    "workspace ${space}"
  ];
  move-to-monitor = which: [
    "move-node-to-monitor ${which}"
    "focus-monitor ${which}"
  ];
  tiling-to = position: [
    "layout tiling"
    "move ${position}"
  ];
in
{
  config = {
    services.aerospace = {
      enable = true;
      settings = {
        default-root-container-layout = "tiles";
        default-root-container-orientation = "auto";
        exec-on-workspace-change = [
          "/bin/sh"
          "-c"
          (trigger "aerospace_workspace_change" "FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE")
        ];
        workspace-to-monitor-force-assignment = {
          "1" = 1;
          "2" = 1;
          "3" = 1;
          "4" = 2;
          "5" = 2;
        };
        gaps = {
          inner.horizontal = 8;
          inner.vertical = 8;
          outer.left = 8;
          outer.bottom = 8;
          outer.top = 30;
          outer.right = 8;
        };
        mode.main.binding = {
          alt-f = (aeroswitch "operation");
          alt-s = (aeroswitch "resize");
          alt-shift-semicolon = (aeroswitch "service");
        };
        mode.service.binding = {
          esc = (aeroswitch "main");
        };
        mode.operation.binding = {
          esc = (aeroswitch "main");
          alt-s = (aeroswitch "resize");
          # workspaces operation
          "1" = "workspace 1";
          "2" = "workspace 2";
          "3" = "workspace 3";
          "4" = "workspace 4";
          "5" = "workspace 5";
          shift-1 = (move-and-focus "1");
          shift-2 = (move-and-focus "2");
          shift-3 = (move-and-focus "3");
          shift-4 = (move-and-focus "4");
          shift-5 = (move-and-focus "5");
          # window
          h = "focus --ignore-floating left";
          j = "focus --ignore-floating down";
          k = "focus --ignore-floating up";
          l = "focus --ignore-floating right";
          f = [
            "layout floating"
            "fullscreen on"
          ];
          shift-h = (tiling-to "left");
          shift-j = (tiling-to "down");
          shift-k = (tiling-to "up");
          shift-l = (tiling-to "right");
          minus = "join-with left";
          equal = "join-with right";
          space = "layout tiles horizontal vertical";
          # multi monitors
          leftSquareBracket = "focus-monitor prev";
          rightSquareBracket = "focus-monitor next";
          shift-leftSquareBracket = (move-to-monitor "prev");
          shift-rightSquareBracket = (move-to-monitor "next");
        };
        mode.resize.binding = {
          enter = (aeroswitch "main");
          esc = (aeroswitch "main");
          alt-f = (aeroswitch "operation");
          h = "resize width -50";
          j = "resize height +50";
          k = "resize height -50";
          l = "resize width +50";
        };
      };
    };
  };
}
