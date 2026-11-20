local label = require("session-label")

require("rex-worktrunk").setup({ base = "@", force_delete = true, label = label })
require("rex-floaters").setup()
require("extensions.tab-numbers")
require("rex-sessionizer").setup({ script = "~/.config/rex/zoxide-picker.sh" })

rex.bind("ctrl+v>ctrl+v", "pane.send_key", { key = "ctrl+v" })
rex.bind("ctrl+v>\\", "pane.split", { direction = "right" })
rex.bind("ctrl+v>-", "pane.split", { direction = "down" })

rex.bind("cmd+n", "session.new")
rex.bind("shift+cmd+n", "client.window.new")
rex.bind("shift+cmd+k", "session.switch")
rex.bind("cmd+s", "client.sidebar.toggle")
rex.bind("cmd+g", "worktree")
rex.bind("shift+cmd+backspace", "worktree_remove")
rex.bind("ctrl+w", "sessionizer")

-- Every tab in every session, in the same order extensions/tab-numbers numbers them
local function all_windows()
  local list = assert(rex.call("session.list"))
  local windows = {}
  for _, session in ipairs(list.sessions) do
    local view = rex.session.view({ session_id = session.session_id })
    for _, window in ipairs(view and view.windows or {}) do
      window.session_id = session.session_id
      window.active = window.window_id == view.active_window_id
      windows[#windows + 1] = window
    end
  end
  return windows
end

-- Without the server-side focus, the next press reads a stale active tab and bounces between two tabs
local function go_to(session_id, window_id)
  rex.session.focus_window({ session_id = session_id, window_id = window_id })
  rex.client.queue("session.select", { session_id = session_id, window_id = window_id })
end

local function step_tab(ctx, step)
  local windows, current = all_windows(), 1
  for i, window in ipairs(windows) do
    if window.session_id == ctx.session_id and window.active then
      current = i
    end
  end
  local target = windows[(current - 1 + step) % #windows + 1]
  go_to(target.session_id, target.window_id)
end

rex.action({
  name = "tab_goto_across_sessions",
  title = "Go to Tab Across Sessions",
  args = { index = "integer" },
  run = function(_, args)
    local windows = all_windows()
    local target = windows[args.index == 9 and #windows or args.index]
    if target then
      go_to(target.session_id, target.window_id)
    end
  end,
})

for index = 1, 9 do
  rex.bind("cmd+" .. index, "tab_goto_across_sessions", { index = index })
end

-- Attention: cmd+. opens the activity sidebar, then cmd+j/cmd+k step through agents waiting on me
local attention_states = { blocked = true, error = true, done = true }

local function needs_attention(pane)
  local status = rex.call("com.superlogical.terminal.program_status", {
    session_id = pane.session_id,
    block_id = pane.block_id,
    args = {},
  })
  for _, record in ipairs(status and status.records or {}) do
    if attention_states[record.state] then
      return true
    end
  end
  return false
end

local function step_attention(ctx, step)
  local panes, current = {}, 1
  for _, window in ipairs(all_windows()) do
    for _, layer in ipairs(window.layers or {}) do
      for _, block in ipairs(layer.blocks or {}) do
        panes[#panes + 1] = { session_id = window.session_id, window_id = window.window_id, block_id = block.block_id }
        if block.block_id == ctx.block_id then
          current = #panes
        end
      end
    end
  end

  for offset = 1, #panes - 1 do
    local pane = panes[(current - 1 + offset * step) % #panes + 1]
    if needs_attention(pane) then
      rex.session.focus_block({ session_id = pane.session_id, block_id = pane.block_id })
      rex.client.queue("session.select", { session_id = pane.session_id, window_id = pane.window_id })
      return
    end
  end
end

-- A flag file rather than a key mode, because Rex shows a bar for as long as a mode is active
local state_dir = os.getenv("HOME") .. "/.local/state/rex"

local function attention_flag(ctx)
  return (state_dir .. "/attention-" .. (ctx.client_id or "local"):gsub("[^%w_-]", "_"))
end

local function attention_on(ctx)
  local file = io.open(attention_flag(ctx), "r")
  if file then
    file:close()
  end
  return file ~= nil
end

rex.action({
  name = "attention_toggle",
  title = "Toggle Attention",
  run = function(ctx)
    if attention_on(ctx) then
      os.remove(attention_flag(ctx))
    else
      rex.exec({ "mkdir", "-p", state_dir })
      assert(io.open(attention_flag(ctx), "w")):close()
    end
    rex.client.queue("client.sidebar.activity.toggle")
  end,
})

for name, step in pairs({ next = 1, previous = -1 }) do
  rex.action({
    name = name .. "_tab_or_agent",
    title = (name == "next" and "Next" or "Previous") .. " Tab, or Agent Needing Attention",
    run = function(ctx)
      if attention_on(ctx) then
        step_attention(ctx, step)
      else
        step_tab(ctx, step)
      end
    end,
  })
end

rex.bind("cmd+.", "attention_toggle")
rex.bind("cmd+j", "next_tab_or_agent")
rex.bind("cmd+k", "previous_tab_or_agent")

-- >>> rex-agent-resume
-- Starts the rex-agent-resume watcher whenever the server loads this file.
dofile("/Users/Oli/.local/share/rex-agent-resume/plugin.lua")
-- <<< rex-agent-resume
