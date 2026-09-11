local apps = require("lib.apps")
local util = require("lib.util")

local PROMPTER = "Elgato"
local MONITOR = "DELL"

-- Tracks the popped-out Meet window across presses so repeat presses cycle
-- its position instead of re-hunting for a Meet tab every time.
local meetWindowId = nil

local function cycle(win)
  local prompter = util.screenMatching(PROMPTER)
  local monitor = util.screenMatching(MONITOR)
  local onPrompter = prompter and win:screen():id() == prompter:id()

  if onPrompter and monitor then
    win:moveToScreen(monitor)
    hs.grid.set(win, "0,2 2x2")
  elseif prompter then
    win:moveToScreen(prompter)
    hs.grid.set(win, util.GRID.full)
  end
end

local function place(win)
  local prompter = util.screenMatching(PROMPTER)
  if not prompter then
    hs.alert.show("Prompter not connected")
    return
  end

  win:moveToScreen(prompter)
  hs.grid.set(win, util.GRID.full)
  meetWindowId = win:id()
end

local M = {}

---Pop the Meet call into its own window on the prompter, cycling on repeat presses
---@return nil
function M.sendToPrompter()
  -- Title check guards against a stale/reused window id (e.g. the window
  -- closed and macOS handed the id to something else, or it got navigated
  -- away from Meet) still passing hs.window.get.
  local existing = meetWindowId and hs.window.get(meetWindowId)
  if existing and existing:title():find("Meet", 1, true) then
    cycle(existing)
    return
  end
  meetWindowId = nil

  local tab = apps.selectChromeTab("https://meet.google.com")
  if not tab then
    hs.alert.show("No Google Meet tab found")
    return
  end

  local app = hs.application.get("Google Chrome")

  -- Match on title rather than trusting app:mainWindow(), since Chrome's
  -- AppleScript "front window" and Accessibility's "main window" can disagree.
  -- AppleScript's title is just the tab title; Hammerspoon's includes a
  -- " - Google Chrome - <profile>" suffix, so match on prefix, not equality.
  local win = hs.fnutils.find(app:allWindows(), function(w)
    return w:title():sub(1, #tab.title) == tab.title
  end)
  if not win then
    hs.alert.show("Couldn't locate Meet window")
    return
  end
  win:focus()

  hs.timer.doAfter(0.2, function()
    if tab.tabCount == 1 then
      place(win)
      return
    end

    local before = {}
    for _, w in ipairs(app:allWindows()) do
      before[w:id()] = true
    end

    app:selectMenuItem({ "Tab", "Move Tab to New Window" })

    hs.timer.doAfter(0.3, function()
      local newWin = hs.fnutils.find(app:allWindows(), function(w)
        return not before[w:id()]
      end)
      if not newWin then
        hs.alert.show("Couldn't locate popped-out window")
        return
      end
      place(newWin)
    end)
  end)
end

return M
