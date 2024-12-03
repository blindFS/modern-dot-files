local wezterm = require("wezterm")
local config = {}

config.color_scheme = "colorscheme_place_holder"
config.colors = {
	background = "black",
	brights = {
		"#a9b1d6",
		"#f7567e",
		"#0dcf6f",
		"#e0ed88",
		"#7dcfff",
		"#dbaaf7",
		"#17d8df",
		"#dddddd",
	},
}
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.window_background_opacity = 0.8
-- config.macos_window_background_blur = 20
config.window_decorations = "RESIZE"
config.font = wezterm.font("monofont_place_holder", { weight = "Regular", stretch = "Expanded", style = "Normal" })
config.font_size = 15.0
config.set_environment_variables = {
	XDG_CONFIG_HOME = os.getenv("HOME") .. "/.config",
}
config.default_prog = {
	"tmux",
}

-- local mux = wezterm.mux
-- wezterm.on("gui-startup", function()
--   local tab, pane, window = mux.spawn_window{}
--   window:gui_window():maximize()
-- end)

return config
