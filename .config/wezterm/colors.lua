local wezterm = require("wezterm")

local function scheme_for_appearance()
  local appearance = wezterm.gui.get_appearance()
  if appearance:find("Dark") then
    return "onedarkpro_vaporwave"
  end
  return "onedarkpro_onelight"
end

wezterm.on("window-config-reloaded", function(window)
  local new_scheme = scheme_for_appearance()
  window:set_config_overrides({
    color_scheme = new_scheme,
  })
  wezterm.log_info("Active window color scheme updated to " .. new_scheme)
end)

local function colors(config)
  config.color_scheme_dirs = { wezterm.home_dir .. "/.cache/nvim/onedarkpro_dotfiles/extras/wezterm" }
  config.color_scheme = scheme_for_appearance()
end

return colors
