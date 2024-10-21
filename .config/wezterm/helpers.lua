local wezterm = require("wezterm")

local M = {}

---Get the current appearance of the terminal
---@return string
function M.mode()
  if wezterm.gui then
    return wezterm.gui.get_appearance() -- "Dark" or "Light"
  end
  return "Dark"
end

return M
