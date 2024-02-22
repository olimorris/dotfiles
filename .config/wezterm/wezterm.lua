local wezterm = require("wezterm")
local config = {}

config.color_scheme = "onedarkpro_onedark"
config.cursor_blink_rate = 0
config.enable_tab_bar = false -- Using tmux instead...yes I know!!
config.font = wezterm.font("Operator Mono", {
  stretch = "Normal",
  weight = "Book",
})
config.font_size = 21
config.hide_tab_bar_if_only_one_tab = true
config.keys = {
  { key = "\r", mods = "CTRL", action = wezterm.action({ SendString = "\x1b[13;5u" }) },
  { key = "\r", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b[13;2u" }) },
  { key = "LeftArrow", mods = "ALT", action = wezterm.action({ SendString = "\x1b\x62" }) },
  { key = "RightArrow", mods = "ALT", action = wezterm.action({ SendString = "\x1b\x66" }) },
}
config.line_height = 1.6
config.mouse_bindings = {
  -- Open a link
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = "OpenLinkAtMouseCursor",
  },
}
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "RESIZE"
config.window_padding = {
  left = 5,
  right = 5,
  top = 0,
  bottom = 0,
}

return config
