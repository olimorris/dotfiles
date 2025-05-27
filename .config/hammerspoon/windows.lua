local hyper = Hyper
local window = require("hs.window")

-- [[ Key Bindings ]] ---------------------------------------------------------
local win_keys = { "alt" }
local win_shift_keys = { "alt", "shift" }

-- [[ Settings ] --------------------------------------------------------------
window.animationDuration = 0.0
hs.grid.setGrid("60x20")
hs.grid.setMargins("0x0")

-- [[ Constants ]] ------------------------------------------------------------

local POSITIONS = {
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
hs.hotkey.bind(win_keys, "Left", function()
  local win = hs.window.focusedWindow()
  if win then
    hs.grid.set(win, POSITIONS.halves.left)
  end
end)
hs.hotkey.bind(win_keys, "Right", function()
  local win = hs.window.focusedWindow()
  if win then
    hs.grid.set(win, POSITIONS.halves.right)
  end
end)

-- Thirds
hs.hotkey.bind(hyper, "1", function()
  local win = hs.window.focusedWindow()
  if win then
    hs.grid.set(win, POSITIONS.thirds.left)
  end
end)
hs.hotkey.bind(hyper, "2", function()
  local win = hs.window.focusedWindow()
  if win then
    hs.grid.set(win, POSITIONS.thirds.center)
  end
end)
hs.hotkey.bind(hyper, "3", function()
  local win = hs.window.focusedWindow()
  if win then
    hs.grid.set(win, POSITIONS.thirds.right)
  end
end)

-- Two-Thirds
hs.hotkey.bind(hyper, "Left", function()
  local win = hs.window.focusedWindow()
  if win then
    hs.grid.set(win, POSITIONS.twoThirds.left)
  end
end)
hs.hotkey.bind(hyper, "Right", function()
  local win = hs.window.focusedWindow()
  if win then
    hs.grid.set(win, POSITIONS.twoThirds.right)
  end
end)
