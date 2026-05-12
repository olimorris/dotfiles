local window = require("hs.window")

-- [[ Key Bindings ]] ---------------------------------------------------------
local win_keys = { "alt" }

-- [[ Settings ] --------------------------------------------------------------
window.animationDuration = 0.0

-- [[ Constants ]] ------------------------------------------------------------
local POSITIONS = {
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

local DIRECTIONS = {
  down = { neighbor = "toSouth", reverseNeighbor = "toNorth", target = "bottom" },
  left = { neighbor = "toWest", reverseNeighbor = "toEast", target = "left" },
  right = { neighbor = "toEast", reverseNeighbor = "toWest", target = "right" },
  up = { neighbor = "toNorth", reverseNeighbor = "toSouth", target = "top" },
}

local function snapHalf(direction)
  local win = hs.window.focusedWindow()
  if not win then
    return
  end
  hs.grid.set(win, POSITIONS.halves[DIRECTIONS[direction].target])
end

local function moveToAdjacent(direction)
  local win = hs.window.focusedWindow()
  if not win then
    return
  end

  local d = DIRECTIONS[direction]
  local screen = win:screen()
  local adjacent = screen[d.neighbor](screen)

  if not adjacent then
    adjacent = screen
    while adjacent[d.reverseNeighbor](adjacent) do
      adjacent = adjacent[d.reverseNeighbor](adjacent)
    end
  end

  if adjacent ~= screen then
    win:moveToScreen(adjacent)
  end
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
local modalAlert = nil

function modal:entered()
  modalAlert = hs.alert.show("Window Mode", hs.alert.defaultStyle, hs.screen.mainScreen(), 999999)
end
function modal:exited()
  if modalAlert then
    hs.alert.closeSpecific(modalAlert)
    modalAlert = nil
  end
end

-- Halves on the current screen
modal:bind({}, "h", function()
  snapHalf("left")
end)
modal:bind({}, "j", function()
  moveToAdjacent("down")
end)
modal:bind({}, "k", function()
  moveToAdjacent("up")
end)
modal:bind({}, "l", function()
  snapHalf("right")
end)

-- Move to the adjacent monitor (wraps around)
modal:bind({}, "left", function()
  moveToAdjacent("left")
end)
modal:bind({}, "down", function()
  moveToAdjacent("down")
end)
modal:bind({}, "up", function()
  moveToAdjacent("up")
end)
modal:bind({}, "right", function()
  moveToAdjacent("right")
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

-- Exit modal
modal:bind({}, "escape", function()
  modal:exit()
end)
modal:bind({}, "q", function()
  modal:exit()
end)
