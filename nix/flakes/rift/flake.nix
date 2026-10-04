{
  description = "Rift — a tiling window manager for macOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      version = "0.6.4";

      mkRift =
        pkgs:
        pkgs.stdenv.mkDerivation {
          pname = "rift";
          inherit version;

          src = pkgs.fetchurl {
            url = "https://github.com/acsandmann/rift/releases/download/v${version}/rift-universal-macos-${version}.tar.gz";
            hash = "sha256-wOJb7GcByJZ1GvZKeH3f79h0bKlXgLM8+GsIlPNCO5Q=";
          };

          sourceRoot = ".";

          installPhase = ''
            runHook preInstall
            install -Dm755 rift $out/bin/rift
            install -Dm755 rift-cli $out/bin/rift-cli
            install -Dm644 rift.default.toml $out/share/rift/rift.default.toml
            runHook postInstall
          '';

          # The artifact is a `lipo` of two separately signed slices, and lipo
          # merges the slices but not their signatures, so the fat binary's
          # signature does not validate. macOS TCC keys an Accessibility grant to
          # the code signature, so with none the grant can never be recorded and
          # rift re-prompts for permission forever. An ad-hoc re-sign gives it a
          # real designated requirement. This must be postFixup: fixupPhase
          # strips the binary, and any write invalidates a signature.
          postFixup = ''
            /usr/bin/codesign --force --sign - $out/bin/rift $out/bin/rift-cli
          '';

          doInstallCheck = true;
          installCheckPhase = ''
            runHook preInstallCheck
            test "$($out/bin/rift --version)" = "rift ${version}"
            test "$($out/bin/rift-cli --version)" = "rift-cli ${version}"
            /usr/bin/codesign --verify --strict $out/bin/rift
            /usr/bin/codesign --verify --strict $out/bin/rift-cli
            runHook postInstallCheck
          '';

          meta = {
            description = "A tiling window manager for macOS";
            homepage = "https://github.com/acsandmann/rift";
            license = pkgs.lib.licenses.asl20;
            platforms = systems;
            mainProgram = "rift";
          };
        };
    in
    {
      packages = forAllSystems (pkgs: rec {
        rift = mkRift pkgs;
        default = rift;
      });

      darwinModules.rift =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.services.rift;
          tomlFormat = pkgs.formats.toml { };

          # rift reads `~/.config/rift/config.toml` by default, but `--config`
          # overrides it, which is what lets nix own the config in the store
          # instead of writing into $HOME. A changed config lands on a new store
          # path, which changes the agent's argv, which makes launchd restart it.
          configPath =
            if cfg.configFile != null then
              cfg.configFile
            else if cfg.config != { } then
              tomlFormat.generate "rift-config.toml" cfg.config
            else
              null;
        in
        {
          options.services.rift = {
            enable = lib.mkEnableOption "the rift tiling window manager";

            package = lib.mkOption {
              type = lib.types.package;
              default = self.packages.${pkgs.stdenv.hostPlatform.system}.rift;
              defaultText = lib.literalExpression "rift.packages.\${system}.rift";
              description = "The rift package, which provides `rift` and `rift-cli`.";
            };

            config = lib.mkOption {
              type = tomlFormat.type;
              default = { };
              description = ''
                rift configuration, serialised to TOML and handed to the agent's
                `--config` flag. This is the whole document, so the top-level
                tables live here: `settings`, `keys`, `binding_modes`,
                `virtual_workspaces`. rift requires `settings` and `keys`, and
                rejects unknown tables.
              '';
            };

            configFile = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              description = ''
                Path to an existing `config.toml`, used instead of
                {option}`services.rift.config`.
              '';
            };
          };

          config = lib.mkIf cfg.enable {
            assertions = [
              {
                assertion = cfg.config == { } || (cfg.config ? settings && cfg.config ? keys);
                message = ''
                  `services.rift.config` must define both the `settings` and
                  `keys` tables; rift rejects a config that is missing either.
                '';
              }
            ];

            environment.systemPackages = [ cfg.package ];

            # rift is a GUI agent: it needs the Aqua session and Accessibility.
            launchd.user.agents.rift = {
              managedBy = "services.rift.enable";

              serviceConfig = {
                # Upstream's `rift service install` writes
                # ~/Library/LaunchAgents/git.acsandmann.rift.plist. Reusing its
                # label makes nix own that exact file, so the two cannot install
                # competing agents. nix-darwin would default to `org.nixos.rift`.
                Label = "git.acsandmann.rift";

                # Run the binary directly rather than through nix-darwin's
                # `command`, which wraps it in `/bin/sh -c` — the shell would
                # take the Accessibility attribution instead of rift.
                ProgramArguments = [
                  "${cfg.package}/bin/rift"
                ]
                ++ lib.optionals (configPath != null) [
                  "--config"
                  (toString configPath)
                ];

                RunAtLoad = true;
                KeepAlive = {
                  SuccessfulExit = false;
                  Crashed = true;
                };
                ProcessType = "Interactive";
                LimitLoadToSessionType = "Aqua";
                Nice = -20;

                # Upstream logs here so a silent failure stays diagnosable.
                StandardOutPath = "/tmp/rift_${config.system.primaryUser}.out.log";
                StandardErrorPath = "/tmp/rift_${config.system.primaryUser}.err.log";
              };

              # `exec` bindings and `run_on_start` resolve against PATH.
              # `environment.systemPath` reads back as an already-joined string.
              path = [
                cfg.package
                config.environment.systemPath
              ];
              environment.RUST_LOG = "error,warn,info";
            };
          };
        };
    };
}
