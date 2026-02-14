{ inputs, self, ... }:
{
  flake.homeManagerModules.security =
    { pkgs, ... }:
    {
      imports = [
        inputs.sops-nix.homeManagerModules.sops
      ];

      home.packages = [
        pkgs.sops
      ];

      # decrypt secrets
      sops.defaultSopsFile = ./secrets/secrets.yaml;
      sops.defaultSopsFormat = "yaml";
      sops.age.keyFile = "/Users/${self.identity.username}/.ssh/nix.key";
      sops.secrets."llm/gemini_api_key" = { };
    };
}
