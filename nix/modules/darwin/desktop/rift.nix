{ self, inputs, ... }:
{
  flake.darwinModules.rift =
    { config, ... }:
    let
      # Shared verbatim with the aerospace module, so one set of sketchybar
      # subscriptions serves either window manager.
      workspace-signal = "wm_workspace_change";
      mode-signal = "wm_mode_change";

      # rift runs `run_on_start` entries as argv, not through a shell, so
      # `/bin/sh -c` is what gets rift's `RIFT_*` event context to sketchybar.
      # rift appends the event JSON as one more argument; `sh -c` ignores it.
      # `subscribe cli` registers with the daemon and returns immediately, so
      # one entry per event is fine.
      on-event =
        event: signal: variables:
        builtins.concatStringsSep " " [
          "rift-cli subscribe cli"
          "--event ${event}"
          "--command /bin/sh"
          "--args -c"
          "--args '${self.sketchybar_exe config} --trigger ${signal} ${variables}'"
        ];

      on-workspace-change =
        on-event "workspace_changed" workspace-signal
          "FOCUSED_WORKSPACE=\"$RIFT_WORKSPACE_NAME\"";
      on-window-change =
        on-event "windows_changed" workspace-signal
          "FOCUSED_WORKSPACE=\"$RIFT_WORKSPACE_NAME\"";
      on-mode-change = on-event "binding_mode_changed" mode-signal "MODE=\"$RIFT_BINDING_MODE\"";

      # rift binds a single command per key, but a binding-mode change is also
      # broadcast as an event, so the switch notifies the bar on its own.
      # `default` is the name of the `[keys]` table, so that is what the other
      # modes return to.
      switch-mode = mode: { binding_mode = mode; };
      switch-workspace = index: { switch_to_workspace = index; };
      move-and-focus = index: {
        move_window_to_workspace = {
          workspace = index;
          follow = true;
        };
      };
      focus = direction: { move_focus = direction; };
      move-node = direction: { move_node = direction; };
      join-with = direction: { join_window = direction; };
      focus-display = direction: { focus_display = direction; };
      move-to-display = direction: {
        move_window_to_display = {
          selector = direction;
        };
      };
      grow-window = axis: { resize_window_grow = axis; };
      shrink-window = axis: { resize_window_shrink = axis; };
    in
    {
      imports = [ inputs.rift.darwinModules.rift ];

      services.rift = {
        enable = true;

        config = {
          settings = {
            animate = true;
            animation_duration = 0.3;
            default_disable = false;
            focus_follows_mouse = true;
            mouse_follows_focus = true;
            mouse_hides_on_focus = true;

            layout = {
              mode = "traditional";
              gaps = {
                outer = {
                  top = 30;
                  left = 8;
                  bottom = 8;
                  right = 8;
                };
                inner = {
                  horizontal = 8;
                  vertical = 8;
                };
              };
            };

            # Re-subscribe on every start: subscriptions live in the rift
            # process, so a restart drops them.
            run_on_start = [
              on-workspace-change
              on-window-change
              on-mode-change
            ];
          };

          virtual_workspaces.default_workspace_count = 5;

          # `[keys]` is the default binding mode.
          keys = {
            "Alt + F" = switch-mode "operation";
            "Alt + S" = switch-mode "resize";
            "Alt + Shift + Semicolon" = switch-mode "service";
          };

          binding_modes = {
            operation = {
              "Escape" = switch-mode "default";
              "Alt + S" = switch-mode "resize";

              "1" = switch-workspace 0;
              "2" = switch-workspace 1;
              "3" = switch-workspace 2;
              "4" = switch-workspace 3;
              "5" = switch-workspace 4;
              "Shift + 1" = move-and-focus 0;
              "Shift + 2" = move-and-focus 1;
              "Shift + 3" = move-and-focus 2;
              "Shift + 4" = move-and-focus 3;
              "Shift + 5" = move-and-focus 4;

              "H" = focus "left";
              "J" = focus "down";
              "K" = focus "up";
              "L" = focus "right";
              "Shift + H" = move-node "left";
              "Shift + J" = move-node "down";
              "Shift + K" = move-node "up";
              "Shift + L" = move-node "right";

              "F" = "toggle_fullscreen_within_gaps";
              "Shift + Space" = "toggle_window_floating";
              "Minus" = join-with "left";
              "Equal" = join-with "right";
              "Space" = "toggle_orientation";

              "BracketLeft" = focus-display "left";
              "BracketRight" = focus-display "right";
              "Shift + BracketLeft" = move-to-display "left";
              "Shift + BracketRight" = move-to-display "right";
            };

            resize = {
              "Enter" = switch-mode "default";
              "Escape" = switch-mode "default";
              "Alt + F" = switch-mode "operation";

              "H" = shrink-window "horizontal";
              "L" = grow-window "horizontal";
              "J" = grow-window "vertical";
              "K" = shrink-window "vertical";
            };

            # aerospace's service mode only exits it; these are rift's own
            # service-level actions.
            service = {
              "Escape" = switch-mode "default";
              "R" = "reload_config";
              "D" = "debug";
            };
          };
        };
      };
    };
}
