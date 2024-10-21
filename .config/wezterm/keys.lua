local wezterm = require("wezterm")
local act = wezterm.action --[[@type function]]

local M = {}

M.mod = "SHIFT|SUPER"

---@param config table
function M.setup(config)
  config.keys = {
    { key = "\r", mods = "CTRL", action = act({ SendString = "\x1b[13;5u" }) },
    { key = "\r", mods = "SHIFT", action = act({ SendString = "\x1b[13;2u" }) },
    { key = "LeftArrow", mods = "ALT", action = act({ SendString = "\x1b\x62" }) },
    { key = "RightArrow", mods = "ALT", action = act({ SendString = "\x1b\x66" }) },

    { key = "d", mods = M.mod, action = act.ShowDebugOverlay },
  }
end

return M
