{
  lib,
  pkgs,
  inputs,
  username,
  colorscheme,
  monofont,
  config,
  ...
}:
let
  zshrc = builtins.readFile ./dotfiles/zshrc;
  wezterm = builtins.readFile ./dotfiles/wezterm.lua;
  colorscheme-dash = builtins.replaceStrings [ "_" ] [ "-" ] colorscheme;
  style-format =
    input-str:
    {
      dash ? false,
    }:
    builtins.replaceStrings
      [ "@@colorscheme@@" "@@monofont@@" ]
      [
        (if dash then colorscheme-dash else colorscheme)
        monofont
      ]
      input-str;
in
{
  imports = [
    ./tmux.nix
    ./bat.nix
    ./git.nix
    ./starship.nix
    ./nushell.nix
    ./sketchybar.nix
    inputs.sops-nix.homeManagerModules.sops
  ];

  # decrypt secrets
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/Users/${username}/.ssh/nix.key";
  sops.secrets."llm/gemini_api_key" = { };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = username;
  home.homeDirectory = lib.mkForce "/Users/${username}";

  # Packages that should be installed to the user profile.
  home.packages = [ ];

  home.sessionVariables.EDITOR = "nvim";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.file.".zshrc".text = style-format zshrc { dash = true; };
  xdg.configFile = {
    "wezterm/wezterm.lua".text = style-format wezterm { };
    "carapace/bridge/zsh/.zshrc" = {
      text =
        # sh
        ''
          fpath=(/run/current-system/sw/share/zsh/site-functions \
            $XDG_CONFIG_HOME/carapace/bridge/zsh/site-functions \
            $fpath)
          autoload -U compinit && compinit
        '';
      onChange = ''${pkgs.carapace}/bin/carapace --clear-cache'';
    };
    "nushell/auth/llm.nu".text =
      # nu
      ''
        $env.GOOGLE_API_KEY = (open ${config.sops.secrets."llm/gemini_api_key".path})
        $env.GEMINI_API_KEY = $env.GOOGLE_API_KEY
      '';
    "lazygit/config.yml".text =
      style-format
        # yaml
        ''
          gui:
            nerdFontsVersion: "3"

          git:
            paging:
              colorArg: always
              pager: delta --paging=never --diff-so-fancy --syntax-theme=${colorscheme}
        ''
        { };
  };
}
