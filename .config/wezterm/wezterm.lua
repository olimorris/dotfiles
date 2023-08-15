local wezterm = require("wezterm")
local config = {}

if wezterm.config_builder then config = wezterm.config_builder() end

config.hide_tab_bar_if_only_one_tab = true

config.color_scheme = "onedarkpro_onedark"

config.line_height = 1.6

config.font_size = 21
config.font = wezterm.font("Operator Mono", { weight = "Book" })
config.font_rules = {
  -- Bold
  {
    intensity = "Bold",
    italic = false,
    font = wezterm.font("Operator Mono", { stretch = "Expanded", weight = "Bold" }),
  },
  -- Bold-and-italic
  {
    intensity = "Bold",
    italic = true,
    font = wezterm.font("Operator Mono", { stretch = "Expanded", italic = true, weight = "Bold" }),
  },
}

config.window_padding = {
  left = 5,
  right = 5,
  top = 0,
  bottom = 0,
}
config.window_decorations = "RESIZE"
config.window_close_confirmation = 'NeverPrompt'

return config
