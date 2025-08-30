const app_icons = {
  'app store': ''
  'arc': '󰣇'
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
  'kicad': ''
  'mail': ''
  'maps': ''
  'music': ''
  'notes': '󰎚'
  'openscad': ''
  'photos': ''
  'podcasts': ''
  'preview': ''
  'safari': '󰀹'
  'steam helper': '󰓓'
  'system settings': '󰒓'
  'wechat': ''
  'zed': '󰬡'
}

export def get_icon_by_app_name []: string -> string {
  let name = $in | str trim | str downcase
  $app_icons
  | get -o $name
  | default ''
}
