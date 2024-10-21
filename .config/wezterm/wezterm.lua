local wezterm = require("wezterm")
local helpers = require("helpers")
local config = wezterm.config_builder()

require("keys").setup(config)
require("tabs").setup(config)
require("workspaces").setup(config)
wezterm.log_info("Reloading")

---Set the color scheme based on the appearance
local function scheme()
  if helpers.mode():find("Dark") then
    return "onedarkpro_onedark"
  end
  return "onedarkpro_onelight"
end
config.color_scheme_dirs = { wezterm.home_dir .. "/Code/Neovim/onedarkpro.nvim/extras/wezterm" }
config.color_scheme = scheme()
wezterm.add_to_config_reload_watch_list(config.color_scheme_dirs[1] .. config.color_scheme .. ".toml")

config.cursor_blink_rate = 0
config.default_workspace = "Oli"

config.font = wezterm.font("Operator Mono", {
  stretch = "Normal",
  weight = "Book",
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
