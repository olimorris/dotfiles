local window = require("hs.window")

-- [[ Key Bindings ]] ---------------------------------------------------------
local win_keys = { "alt" }
local win_shift_keys = { "alt", "shift" }

-- [[ Settings ] --------------------------------------------------------------
window.animationDuration = 0.0
hs.grid.setGrid("60x20")
hs.grid.setMargins("0x0")

-- [[ Constants ]] ------------------------------------------------------------
DISPLAYS = {
  internal = "Built-in Retina Display",
  external = "DELL U3818DW",
}

POSITIONS = {
  full = "0,0 60x20",
  halves = {
    left = "0,0 30x20",
    right = "30,0 30x20",
  },
  thirds = {
    left = "0,0 20x20",
    center = "20,0 20x20",
    right = "40,0 20x20",
  },
  twoThirds = {
    left = "0,0 40x20",
    right = "20,0 40x20",
  },
  center = {
    large = "6,1 48x18",
    medium = "12,1 36x18",
    small = "16,2 28x16",
  },
  p1080 = function(opts)
    opts = opts or {}
    local chromeOffset = opts.chrome and 87 or 0

    local dellScreen = nil
    for _, screen in pairs(hs.screen.allScreens()) do
      if screen:name() == DISPLAYS.external then
        dellScreen = screen
        break
      end
    end

    if dellScreen then
      local screenFrame = dellScreen:frame()
      return hs.geometry.rect(
        screenFrame.x + 25,
        screenFrame.y + 25, -- Keep Y position consistent
        1920,
        1080 + chromeOffset -- Just extend height for Chrome
      )
    else
      return hs.geometry.rect(25, 25, 1920, 1080 + chromeOffset)
    end
  end,
}

-- [[ Window Management ]] -----------------------------------------------------

-- Maximize the focused window
hs.hotkey.bind(win_keys, "M", function()
  local win = hs.window.focusedWindow()
  if win then
    win:maximize()
  end
end)

-- Halves
hs.hotkey.bind(Hyper, "Left", function()
  local win = hs.window.focusedWindow()
  if win then
    hs.grid.set(win, POSITIONS.halves.left)
  end
end)
hs.hotkey.bind(Hyper, "Right", function()
  local win = hs.window.focusedWindow()
  if win then
    hs.grid.set(win, POSITIONS.halves.right)
  end
end)

-- Thirds
hs.hotkey.bind(Hyper, "1", function()
  local win = hs.window.focusedWindow()
  if win then
    hs.grid.set(win, POSITIONS.thirds.left)
  end
end)
hs.hotkey.bind(Hyper, "2", function()
  local win = hs.window.focusedWindow()
  if win then
    hs.grid.set(win, POSITIONS.thirds.center)
  end
end)
hs.hotkey.bind(Hyper, "3", function()
  local win = hs.window.focusedWindow()
  if win then
    hs.grid.set(win, POSITIONS.thirds.right)
  end
end)

hs.hotkey.bind(Hyper, "4", function()
  local win = hs.window.focusedWindow()
  if win then
    win:setFrame(POSITIONS.p1080())
  end
end)

hs.hotkey.bind(Hyper, "5", function()
  local win = hs.window.focusedWindow()
  if win then
    win:setFrame(POSITIONS.p1080({ chrome = true }))
  end
end)

-- Two-Thirds
hs.hotkey.bind(win_shift_keys, "Left", function()
  local win = hs.window.focusedWindow()
  if win then
    hs.grid.set(win, POSITIONS.twoThirds.left)
  end
end)
hs.hotkey.bind(win_shift_keys, "Right", function()
  local win = hs.window.focusedWindow()
  if win then
    hs.grid.set(win, POSITIONS.twoThirds.right)
  end
end)

-- Center the application
hs.hotkey.bind(win_keys, "C", function()
  local win = hs.window.focusedWindow()
  if win then
    local winFrame = win:frame()
    local screenFrame = win:screen():frame()

    local newX = screenFrame.x + (screenFrame.w - winFrame.w) / 2
    local newY = screenFrame.y + (screenFrame.h - winFrame.h) / 2

    win:setTopLeft({ x = newX, y = newY })
  end
end)

-- Move focused window to next screen
local function moveAndResizeWindow(getDestinationScreenFn)
  local win = hs.window.focusedWindow()
  if win then
    local destinationScreen = getDestinationScreenFn(win:screen())
    if destinationScreen then
      win:moveToScreen(destinationScreen)

      -- After moving, get the screen the window is now on
      local newScreenOfWindow = win:screen()

      if newScreenOfWindow:name() == DISPLAYS.internal then
        hs.grid.set(win, POSITIONS.full, newScreenOfWindow)
      else
        -- If not internal, set to half. Adjust POSITIONS.halves.left if needed.
        hs.grid.set(win, POSITIONS.halves.left, newScreenOfWindow)
      end
    end
  end
end
hs.hotkey.bind(Hyper, "Up", function()
  moveAndResizeWindow(function(currentScreen)
    return currentScreen:next()
  end)
end)
hs.hotkey.bind(Hyper, "Down", function()
  moveAndResizeWindow(function(currentScreen)
    return currentScreen:previous()
  end)
end)
