local wezterm = require 'wezterm'
local config = {}

config.color_scheme = 'Adventure'
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.window_background_opacity = 0.8
config.window_decorations = "RESIZE"
config.font = wezterm.font("Sarasa Term SC Nerd", {weight="DemiBold", stretch="Normal", style="Normal"})
config.font_size  = 15.0
config.set_environment_variables = {
  XDG_CONFIG_HOME = os.getenv("HOME") .. '/.config',
}
config.default_prog = {'/usr/local/bin/tmux'}

local mux = wezterm.mux
wezterm.on("gui-startup", function()
  local tab, pane, window = mux.spawn_window{}
  window:gui_window():maximize()
end)

return config
