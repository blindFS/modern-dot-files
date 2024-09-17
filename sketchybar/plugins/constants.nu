# type int
export const colors = {
    fg: 0x88ffffff
    bg: 0x55000000
    white: 0xffffffff
    black: 0xff000000
    dark: 0xcc000000
    transparent: 0x00000000
    yellow: 0xffe0af68
    cyan: 0xff7dcfff
    blue: 0xdd7aa2f7
    green: 0xff0dcf6f
    orange: 0xfff7768e
    purple: 0xffbb9af7
}

# type string
export const mode_colors = {
    main: '0xdd7aa2f7'
    operation: '0xfff7768e'
    resize: '0xff0dcf6f'
    service: '0xffffffff'
}


export const app_icons = {
    'app store': 
    'steam helper':  󰓓
    'system settings': 󰒓
    arc: 󰣇
    books: 
    calculator: 
    calendar: 
    code: 󰨞
    dictionary: 
    discord: 󰙯
    emacs: 
    finder: 󰀶
    gimp: 
    mail: 
    maps: 
    music: 
    notes: 󰎚
    photos: 
    podcasts: 
    preview: 
    safari: 󰀹
    wechat: 
    wezterm: 
}

export def get_icon_by_app_name [] string -> string {
    let name = $in | str downcase
    $app_icons
    | get -i $name
    | default ''
}
