local util = require("lib.util")
local window = require("hs.window")

-- [[ Key Bindings ]] ---------------------------------------------------------
local win_keys = { "alt" }

-- [[ Settings ] --------------------------------------------------------------
window.animationDuration = 0.0

-- [[ Constants ]] ------------------------------------------------------------
---A 1080p-ish frame, inset from the screen edges
---@param opts? { chrome?: boolean } chrome adds room for a browser's toolbar
---@return table
local function p1080(opts)
  opts = opts or {}
  local chromeOffset = opts.chrome and 87 or 0

  local screen = hs.screen.mainScreen() or hs.screen.primaryScreen()
  local screenFrame = screen:frame()

  local w = math.min(1920, math.max(100, screenFrame.w - 50))
  local h = math.min(1080 + chromeOffset, math.max(100, screenFrame.h - 50))

  return hs.geometry.rect(screenFrame.x + 25, screenFrame.y + 25, w, h)
end

local DIRECTIONS = {
  down = { neighbor = "toSouth", reverseNeighbor = "toNorth", target = "bottom" },
  left = { neighbor = "toWest", reverseNeighbor = "toEast", target = "left" },
  right = { neighbor = "toEast", reverseNeighbor = "toWest", target = "right" },
  up = { neighbor = "toNorth", reverseNeighbor = "toSouth", target = "top" },
}

local function snapTo(grid_settings)
  return util.onFocusedWindow(function(win)
    hs.grid.set(win, grid_settings)
  end)
end

local function frameTo(builder, opts)
  return util.onFocusedWindow(function(win)
    win:setFrame(builder(opts))
  end)
end

---Move to the neighbouring screen, wrapping around at the far edge
local function moveToAdjacent(direction)
  return util.onFocusedWindow(function(win)
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
  end)
end

-- [[ Window Management ]] -----------------------------------------------------
hs.hotkey.bind(
  win_keys,
  "m",
  util.onFocusedWindow(function(win)
    win:maximize()
  end)
)

hs.hotkey.bind(
  win_keys,
  "c",
  util.onFocusedWindow(function(win)
    win:centerOnScreen()
  end)
)

-- [[ Modal Window Management ]] -----------------------------------------------
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

---Any action leaves the modal, so it can't be left listening after a keypress
local function bind(key, action)
  modal:bind({}, key, function()
    action()
    modal:exit()
  end)
end

-- Halves on the current screen
bind("h", snapTo(util.GRID.halves.left))
bind("l", snapTo(util.GRID.halves.right))

bind("j", moveToAdjacent("down"))
bind("k", moveToAdjacent("up"))

-- Move to the adjacent monitor (wraps around)
bind("left", moveToAdjacent("left"))
bind("down", moveToAdjacent("down"))
bind("up", moveToAdjacent("up"))
bind("right", moveToAdjacent("right"))

-- Thirds and fixed-size frames
bind("1", snapTo(util.GRID.thirds.left))
bind("2", snapTo(util.GRID.thirds.center))
bind("3", snapTo(util.GRID.thirds.right))
bind("4", frameTo(p1080))
bind("5", frameTo(p1080, { chrome = true }))

-- Exit modal
modal:bind({}, "escape", function()
  modal:exit()
end)
modal:bind({}, "q", function()
  modal:exit()
end)
