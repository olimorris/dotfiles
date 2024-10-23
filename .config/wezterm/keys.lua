local wezterm = require("wezterm")
local act = wezterm.action --[[@type function]]

local mod = "SHIFT|SUPER"

---@param config table
local function keys(config)
  config.keys = {

    -- Scrollback
    { mods = mod, key = "k", action = act.ScrollByPage(-0.5) },
    { mods = mod, key = "j", action = act.ScrollByPage(0.5) },

    -- Get the keys working as expected
    { key = "\r", mods = "CTRL", action = act({ SendString = "\x1b[13;5u" }) },
    { key = "\r", mods = "SHIFT", action = act({ SendString = "\x1b[13;2u" }) },
    { key = "LeftArrow", mods = "ALT", action = act({ SendString = "\x1b\x62" }) },
    { key = "RightArrow", mods = "ALT", action = act({ SendString = "\x1b\x66" }) },

    { key = "d", mods = mod, action = act.ShowDebugOverlay },
  }
end

return keys
