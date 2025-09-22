local window = require("hs.window")

-- [[ Key Bindings ]] ---------------------------------------------------------
local win_keys = { "alt" }

-- [[ Settings ] --------------------------------------------------------------
window.animationDuration = 0.0
hs.grid.setGrid("6x4")
hs.grid.setMargins("0x0")

-- [[ Constants ]] ------------------------------------------------------------
local POSITIONS = {
  halves = {
    left = "0,0 3x4",
    right = "3,0 3x4",
  },
  thirds = {
    left = "0,0 2x4",
    center = "2,0 2x4",
    right = "4,0 2x4",
  },
  p1080 = function(opts)
    opts = opts or {}
    local chromeOffset = opts.chrome and 87 or 0

    local screen = hs.screen.mainScreen() or hs.screen.primaryScreen()
    local screenFrame = screen:frame()

    local w = math.min(1920, math.max(100, screenFrame.w - 50))
    local h = math.min(1080 + chromeOffset, math.max(100, screenFrame.h - 50))

    return hs.geometry.rect(screenFrame.x + 25, screenFrame.y + 25, w, h)
  end,
}

-- Simplified: Move focused window to a destination screen and apply a simple layout.
local function moveAndResizeWindow(getDestinationScreenFn)
  local win = hs.window.focusedWindow()
  if not win then
    return
  end

  local destinationScreen = getDestinationScreenFn(win:screen())
  if not destinationScreen then
    return
  end

  win:moveToScreen(destinationScreen)

  -- Apply a simple default layout (left half on destination screen)
  hs.grid.set(win, POSITIONS.halves.left, destinationScreen)
end

-- [[ Window Management ]] -----------------------------------------------------

-- Maximize the focused window
hs.hotkey.bind(win_keys, "m", function()
  local win = hs.window.focusedWindow()
  if win then
    win:maximize()
  end
end)

-- Center
hs.hotkey.bind(win_keys, "c", function()
  local win = hs.window.focusedWindow()
  if win.centerOnScreen then
    win:centerOnScreen()
    return
  end
end)

-- Modal Window Management
local modal = hs.hotkey.modal.new(Hyper, "W")

function modal:entered()
  hs.alert.show("Window Mode")
end
function modal:exited()
  hs.alert.closeAll()
end

-- Halves
modal:bind({}, "h", function()
  local win = hs.window.focusedWindow()
  if win then
    hs.grid.set(win, POSITIONS.halves.left)
  end
end)
modal:bind({}, "l", function()
  local win = hs.window.focusedWindow()
  if win then
    hs.grid.set(win, POSITIONS.halves.right)
  end
end)

modal:bind({}, "1", function()
  local win = hs.window.focusedWindow()
  if win then
    hs.grid.set(win, POSITIONS.thirds.left)
  end
end)
modal:bind({}, "2", function()
  local win = hs.window.focusedWindow()
  if win then
    hs.grid.set(win, POSITIONS.thirds.center)
  end
end)
modal:bind({}, "3", function()
  local win = hs.window.focusedWindow()
  if win then
    hs.grid.set(win, POSITIONS.thirds.right)
  end
end)
modal:bind({}, "4", function()
  local win = hs.window.focusedWindow()
  if win then
    win:setFrame(POSITIONS.p1080())
  end
end)
modal:bind({}, "5", function()
  local win = hs.window.focusedWindow()
  if win then
    win:setFrame(POSITIONS.p1080({ chrome = true }))
  end
end)

-- Move to next/previous screen
modal:bind({}, "j", function()
  moveAndResizeWindow(function(currentScreen)
    return currentScreen:next()
  end)
end)
modal:bind({}, "k", function()
  moveAndResizeWindow(function(currentScreen)
    return currentScreen:previous()
  end)
end)

-- Exit modal
modal:bind({}, "escape", function()
  modal:exit()
end)
modal:bind({}, "q", function()
  modal:exit()
end)
