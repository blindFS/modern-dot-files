export const app_icons = {
  'app store': ''
  'steam helper': '󰓓'
  'system settings': '󰒓'
  'arc': '󰣇'
  'books': ''
  'calculator': ''
  'calendar': ''
  'code': '󰨞'
  'dictionary': ''
  'discord': '󰙯'
  'emacs': ''
  'finder': '󰀶'
  'gimp': ''
  'mail': ''
  'maps': ''
  'music': ''
  'notes': '󰎚'
  'photos': ''
  'podcasts': ''
  'preview': ''
  'safari': '󰀹'
  'wechat': ''
  'wezterm': ''
}
export def get_icon_by_app_name []: string -> string {
  let name = $in | str trim | str downcase
  $app_icons
  | get -i $name
  | default ''
}
