local wezterm = require("wezterm")

local function scheme_for_appearance(appearance)
  if appearance:find("Dark") then
    return "onedarkpro_vaporwave"
  end
  return "onedarkpro_onelight"
end

local function colors(config)
  config.color_scheme_dirs = { wezterm.home_dir .. "/.cache/nvim/onedarkpro_dotfiles/extras/wezterm" }
  config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())
end

return colors
