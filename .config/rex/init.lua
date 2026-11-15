local label = require("session-label")

require("rex-worktrunk").setup({ base = "@", force_delete = true, label = label })
require("rex-floaters").setup()
require("extensions.tab-numbers")

rex.bind("ctrl+v>ctrl+v", "pane.send_key", { key = "ctrl+v" })
rex.bind("ctrl+v>shift+g", "worktree")
rex.bind("ctrl+v>shift+x", "worktree_remove")

-- Migrated from Herdr (~/.config/herdr/config.toml)
rex.bind("cmd+n", "session.new")

-- Without the server-side focus, the next press reads a stale active tab and bounces between two tabs
local function go_to(session_id, window_id)
  rex.session.focus_window{ session_id = session_id, window_id = window_id }
  rex.client.queue("session.select", { session_id = session_id, window_id = window_id })
end

local function step_tab(ctx, step)
  local view, err = rex.session.view{ session_id = ctx.session_id }
  if not view then error(err, 0) end

  local current = 1
  for i, window in ipairs(view.windows) do
    if window.window_id == view.active_window_id then current = i end
  end

  local target = view.windows[current + step]
  if target then return go_to(ctx.session_id, target.window_id) end

  local list, list_err = rex.call("session.list")
  if not list then error(list_err, 0) end
  local sessions = list.sessions
  if #sessions < 2 then return end

  local here = 1
  for i, session in ipairs(sessions) do
    if session.session_id == ctx.session_id then here = i end
  end
  local next_session = sessions[(here - 1 + step) % #sessions + 1]

  local next_view, view_err = rex.session.view{ session_id = next_session.session_id }
  if not next_view then error(view_err, 0) end
  local window = next_view.windows[step > 0 and 1 or #next_view.windows]
  go_to(next_session.session_id, window.window_id)
end

rex.action{ name = "tab_next_across_sessions", title = "Next Tab Across Sessions", run = function(ctx) step_tab(ctx, 1) end }
rex.action{ name = "tab_previous_across_sessions", title = "Previous Tab Across Sessions", run = function(ctx) step_tab(ctx, -1) end }

-- Same order as extensions/tab-numbers, so cmd+N lands on the tab labelled N
local function all_tabs()
  local list, err = rex.call("session.list")
  if not list then error(err, 0) end
  local tabs = {}
  for _, session in ipairs(list.sessions) do
    local view, view_err = rex.session.view{ session_id = session.session_id }
    if not view then error(view_err, 0) end
    for _, window in ipairs(view.windows) do
      tabs[#tabs + 1] = { session_id = session.session_id, window_id = window.window_id }
    end
  end
  return tabs
end

rex.action{
  name = "tab_goto_across_sessions",
  title = "Go to Tab Across Sessions",
  args = { index = "integer" },
  run = function(_, args)
    local tabs = all_tabs()
    local tab = tabs[args.index == 9 and #tabs or args.index]
    if tab then go_to(tab.session_id, tab.window_id) end
  end,
}

for index = 1, 9 do
  rex.bind("cmd+" .. index, "tab_goto_across_sessions", { index = index })
end

rex.bind("cmd+j", "tab_next_across_sessions")
rex.bind("cmd+k", "tab_previous_across_sessions")
rex.bind("shift+cmd+k", "session.switch")
rex.bind("cmd+s", "client.sidebar.toggle")
rex.bind("ctrl+v>\\", "pane.split", { direction = "right" })
rex.bind("ctrl+v>-", "pane.split", { direction = "down" })

-- Migrated from Ghostty (~/.config/ghostty/config)
rex.bind("shift+cmd+n", "client.window.new")

-- -- Migrated from iTerm2 (Default profile key map): single control bytes
-- rex.bind("ctrl+2", "pane.send_key", { key = "ctrl+shift+2" })
-- rex.bind("ctrl+3", "pane.send_key", { key = "esc" })
-- rex.bind("ctrl+4", "pane.send_key", { key = "ctrl+\\" })
-- rex.bind("ctrl+5", "pane.send_key", { key = "ctrl+]" })
-- rex.bind("ctrl+6", "pane.send_key", { key = "ctrl+shift+6" })
-- rex.bind("ctrl+7", "pane.send_key", { key = "ctrl+shift+-" })
-- rex.bind("ctrl+8", "pane.send_key", { key = "backspace" })
-- rex.bind("ctrl+-", "pane.send_key", { key = "ctrl+shift+-" })
