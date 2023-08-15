local wezterm = require("wezterm")
local config = {}

if wezterm.config_builder then config = wezterm.config_builder() end

config.color_scheme = "onedarkpro_onedark"
config.line_height = 1.5

config.font_size = 21
config.font = wezterm.font("Operator Mono", { weight = "Book" })

config.hide_tab_bar_if_only_one_tab = true

config.window_padding = {
  left = 2,
  right = 2,
  top = 0,
  bottom = 0,
}
config.window_decorations = "RESIZE"

return config
