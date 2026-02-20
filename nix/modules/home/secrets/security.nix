{ inputs, ... }:
{
  flake.homeModules.security =
    { osConfig, pkgs, ... }:
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
        age.keyFile = "${osConfig.environment.variables.HOME}/.ssh/nix.key";
        secrets."llm/gemini_api_key" = { };
      };
    };
}
