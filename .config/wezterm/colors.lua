local wezterm = require("wezterm")

---Fetch the correct color scheme
local function get_color_scheme()
  local file = io.open(wezterm.home_dir .. "/.color_mode", "rb")
  if not file then
    wezterm.log_info("Could not read color")
    return "onedarkpro_onedark"
  end
  local color = file:read("*a")
  file:close()

  if color == "dark" then
    return "onedarkpro_onedark"
  end
  return "onedarkpro_onelight"
end

local function colors(config)
  config.color_scheme_dirs = { wezterm.home_dir .. "/Code/Neovim/onedarkpro.nvim/extras/wezterm" }
  config.color_scheme = get_color_scheme()
  wezterm.add_to_config_reload_watch_list(config.color_scheme_dirs[1] .. "/" .. config.color_scheme .. ".toml")
end

return colors
