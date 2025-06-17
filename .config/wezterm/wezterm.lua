local wezterm = require("wezterm")
local config = wezterm.config_builder()

require("colors")(config)
require("links")(config)
require("keys")(config)
require("tabline")(config)
require("workspaces")(config)
wezterm.log_info("Reloading")

wezterm.add_to_config_reload_watch_list(wezterm.home_dir .. "/.color_mode")
config.automatically_reload_config = true

-- Graphics config
config.front_end = "WebGpu"
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

config.font = wezterm.font("OperatorMono Nerd Font", {
  stretch = "Normal",
  weight = "Medium",
})
config.font_size = 21

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
