const app_icons = {
  'app store': ''
  'arc': '󰣇'
  'betterdisplay': '󰍺'
  'blender': ''
  'books': ''
  'calculator': ''
  'calendar': ''
  'dictionary': ''
  'discord': '󰙯'
  'emacs': ''
  'finder': '󰀶'
  'ghostty': ''
  'gimp': ''
  'google chrome': ''
  'kicad': ''
  'mail': ''
  'maps': ''
  'music': ''
  'neovide': ''
  'notes': '󰎚'
  'openscad': ''
  'photos': ''
  'podcasts': ''
  'preview': ''
  'safari': '󰀹'
  'shadowrocket': ''
  'steam helper': '󰓓'
  'ryujinx': '󱎓'
  'system settings': '󰒓'
  'wechat': ''
  'zed': '󰬡'
  'telegram': ''
}

export def get_icon_by_app_name []: string -> string {
  let name = $in | str trim | str downcase
  $app_icons
  | get -o $name
  | default ''
}
