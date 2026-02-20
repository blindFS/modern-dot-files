{
  flake.homeModules.atuin =
    { ... }:
    {
      programs.atuin = {
        enable = true;
        flags = [
          "--disable-up-arrow"
          "--disable-ctrl-r"
        ];
        settings = {
          auto_sync = false;
          filter_mode = "workspace";
          invert = true;
          store_failed = false;
          history_filter = [
            "^auto_pair_complete"
          ];
        };
      };
    };
}
