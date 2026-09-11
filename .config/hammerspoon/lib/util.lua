local M = {}

-- [[ Grid ]] -----------------------------------------------------------------
M.GRID = {
  full = "0,0 6x4",
  halves = {
    bottom = "0,2 6x2",
    left = "0,0 3x4",
    right = "3,0 3x4",
    top = "0,0 6x2",
  },
  thirds = {
    left = "0,0 2x4",
    center = "2,0 2x4",
    right = "4,0 2x4",
  },
}

-- [[ Screens ]] --------------------------------------------------------------

---@param pattern string Lua pattern matched against the screen name
---@return table|nil
function M.screenMatching(pattern)
  return hs.fnutils.find(hs.screen.allScreens(), function(screen)
    return (screen:name() or ""):find(pattern) ~= nil
  end)
end

---@param pattern string Lua pattern matched against the screen name
---@return table|nil
function M.screenNotMatching(pattern)
  return hs.fnutils.find(hs.screen.allScreens(), function(screen)
    return (screen:name() or ""):find(pattern) == nil
  end)
end

-- [[ Windows ]] --------------------------------------------------------------

---@param win table|nil
---@return nil
function M.centerCursor(win)
  if not win then
    return
  end

  local frame = win:frame()
  hs.mouse.absolutePosition(hs.geometry.point(frame.x + frame.w / 2, frame.y + frame.h / 2))
end

---Wrap a window action into a hotkey callback that no-ops when nothing is focused
---@param fn fun(win: table)
---@return fun()
function M.onFocusedWindow(fn)
  return function()
    local win = hs.window.focusedWindow()
    if win then
      fn(win)
    end
  end
end

return M
