{ inputs, ... }:
{
  flake.homeModules.security =
    { pkgs, ... }:
    {
      imports = [
        inputs.sops-nix.homeManagerModules.sops
      ];

      home.packages = [
        pkgs.sops
      ];

      # decrypt secrets
      sops.defaultSopsFile = ./secrets.yaml;
      sops.defaultSopsFormat = "yaml";
      sops.age.keyFile = "${builtins.getEnv "HOME"}/.ssh/nix.key";
      sops.secrets."llm/gemini_api_key" = { };
    };
}
