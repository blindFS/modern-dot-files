{ inputs, ... }:
{
  flake.homeModules.security =
    { config, pkgs, ... }:
    {
      imports = [
        inputs.sops-nix.homeManagerModules.sops
      ];

      home.packages = [
        pkgs.sops
      ];

      # decrypt secrets
      sops = {
        defaultSopsFile = ./secrets.yaml;
        defaultSopsFormat = "yaml";
        age.keyFile = "${config.home.homeDirectory}/.ssh/nix.key";
        secrets."llm/gemini_api_key" = { };
      };

      home.sessionVariables.GEMINI_API_KEY = "$(cat ${config.sops.secrets."llm/gemini_api_key".path})";
    };
}
