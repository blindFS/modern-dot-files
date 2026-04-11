{ ... }:
{
  # flake.darwinModules.homebrew.homebrewbrews = [
  #   "ollama"
  #   "zeroclaw"
  # ];

  flake.homeModules.llm =
    { pkgs, config, ... }:
    {
      sops.secrets."llm/gemini_api_key" = { };
      home.sessionVariables.GEMINI_API_KEY = "$(cat ${config.sops.secrets."llm/gemini_api_key".path})";

      # services.ollama = {
      #   enable = true;
      #   package = pkgs.ollama;
      #   environmentVariables = {
      #     OLLAMA_NUM_GPU = "99";
      #   };
      # };
    };
}
