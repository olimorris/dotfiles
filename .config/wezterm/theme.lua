local wezterm = require("wezterm")
local M = {}

---@type Mode|nil
local force = nil

---@enum (key) Mode
local theme = {
  dark = "onedarkpro_vaporwave",
  light = "onedarkpro_onelight",
}

---@return Mode
local detect = function()
  if force ~= nil then
    return force
  elseif wezterm.gui and wezterm.gui.get_appearance():find("Light") then
    return "light"
  end
  return "dark"
end

M.set = function(config)
  local mode = detect()
  config.color_scheme_dirs = { wezterm.home_dir .. "/.cache/nvim/onedarkpro_dotfiles/extras/wezterm" }
  config.color_scheme = theme[mode]

  local ok, _, stderr = wezterm.run_child_process({
    "sh",
    "-c",
    'echo "' .. mode .. '" > /tmp/oli-theme',
  })
  if not ok then
    error(stderr, 0)
  end
end

return M
