local wezterm = require("wezterm")
local helpers = require("helpers")

local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

local M = {}

function M.setup(config)
  workspace_switcher.workspace_formatter = function(label)
    return wezterm.format({
      { Attribute = { Italic = true } },
      { Foreground = { AnsiColor = "Purple" } },
      { Background = { Color = (helpers.mode() == "Dark" and "#282c34" or "#fafafa") } },
      { Text = wezterm.nerdfonts.cod_terminal_tmux .. " " .. string.match(label, "[^/\\]+$") },
    })
  end

  table.insert(config.keys, { key = "w", mods = "CTRL", action = workspace_switcher.switch_workspace() })
end

return M
