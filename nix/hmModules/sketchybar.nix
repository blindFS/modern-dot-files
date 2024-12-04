{ colorscheme, monofont, ... }:
let
  cs = import ../colorscheme.nix {
    inherit colorscheme;
    xargb = true;
  };
  color-alpha = hex: alpha: builtins.replaceStrings [ "0xff" ] [ "0x${alpha}" ] hex;
in
{
  xdg.configFile."sketchybar/plugins/style.nu".text =
    # nu
    ''
      # type int
      export const colors = {
        fg: 0x88ffffff
        bg: 0x55000000
        white: 0xffffffff
        black: 0xff000000
        dark: 0xcc000000
        transparent: 0x00000000
        yellow: ${cs.yellow}
        cyan: ${cs.cyan}
        blue: ${color-alpha cs.blue "dd"}
        green: ${cs.light_green}
        orange: ${cs.red}
        purple: ${cs.purple}
      }
      # type string
      export const mode_colors = {
        main: '${color-alpha cs.blue "dd"}'
        operation: '${cs.red}'
        resize: '${cs.light_green}'
        service: '${cs.white}'
      }
      export const monofont = '${monofont}'
    '';
}
