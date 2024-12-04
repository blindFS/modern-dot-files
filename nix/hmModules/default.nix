{
  lib,
  inputs,
  username,
  arch,
  colorscheme,
  monofont,
  ...
}:
let
  zshrc = builtins.readFile ./dotfiles/zshrc;
  wezterm = builtins.readFile ./dotfiles/wezterm.lua;
  style-format =
    input-str:
    {
      dash ? false,
    }:
    builtins.replaceStrings
      [ "colorscheme_place_holder" "monofont_place_holder" ]
      [
        (if dash then (builtins.replaceStrings [ "_" ] [ "-" ] colorscheme) else colorscheme)
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
  ];

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
    "lazygit/config.yml".text = style-format ''
      gui:
        nerdFontsVersion: "3"

      git:
        paging:
          colorArg: always
          pager: delta --paging=never --diff-so-fancy --syntax-theme=colorscheme_place_holder
    '' { };
  };
}
