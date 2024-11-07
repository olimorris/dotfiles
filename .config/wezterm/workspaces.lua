local wezterm = require("wezterm")

local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

local function workspaces(config)
  resurrect.set_encryption({
    enable = true,
    method = "/opt/homebrew/bin/age",
    private_key = wezterm.home_dir .. "/.dotfiles/.config/wezterm/encryption_key.txt",
    public_key = "age1pdme0zrvsp4rphlfuc82lnfdm6gkyuakzajkp7veclk9qckz4ccsevud0w",
  })
  resurrect.periodic_save()
  resurrect.set_max_nlines(1000)

  workspace_switcher.workspace_formatter = function(label)
    return wezterm.format({
      { Attribute = { Italic = true } },
      { Foreground = { AnsiColor = "Purple" } },
      { Background = { Color = (wezterm.gui.get_appearance() == "Dark" and "#282c34" or "#fafafa") } },
      { Text = wezterm.nerdfonts.cod_terminal_tmux .. " " .. string.match(label, "[^/\\]+$") },
    })
  end

  -- Load state whenever a workspace is created
  wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(window, path, label)
    local workspace_state = resurrect.workspace_state

    workspace_state.restore_workspace(resurrect.load_state(label, "workspace"), {
      window = window,
      restore_text = true,
      on_pane_restore = resurrect.tab_state.default_on_pane_restore,
    })
  end)

  -- Save state whenever a workspace is selected
  wezterm.on("smart_workspace_switcher.workspace_switcher.selected", function(window, path, label)
    local workspace_state = resurrect.workspace_state
    resurrect.save_state(workspace_state.get_workspace_state())
  end)

  table.insert(config.keys, { key = "w", mods = "CTRL", action = workspace_switcher.switch_workspace() })
  table.insert(config.keys, {
    key = "s",
    mods = "ALT",
    action = wezterm.action_callback(function(win, pane)
      resurrect.save_state(resurrect.workspace_state.get_workspace_state())
    end),
  })
end

return workspaces
