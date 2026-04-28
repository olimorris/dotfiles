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
  down = { neighbor = "toSouth", opposite = "top", reverseNeighbor = "toNorth", target = "bottom" },
  left = { neighbor = "toWest", opposite = "right", reverseNeighbor = "toEast", target = "left" },
  right = { neighbor = "toEast", opposite = "left", reverseNeighbor = "toWest", target = "right" },
  up = { neighbor = "toNorth", opposite = "bottom", reverseNeighbor = "toSouth", target = "top" },
}

local function snapOrWrap(direction)
  local win = hs.window.focusedWindow()
  if not win then
    return
  end

  local d = DIRECTIONS[direction]
  local screen = win:screen()
  local targetCell = POSITIONS.halves[d.target]
  local frame = win:frame()
  local targetFrame = hs.grid.getCell(targetCell, screen)

  local atEdge = math.abs(frame.x - targetFrame.x) < 5
    and math.abs(frame.y - targetFrame.y) < 5
    and math.abs(frame.w - targetFrame.w) < 5
    and math.abs(frame.h - targetFrame.h) < 5

  if atEdge then
    local adjacent = screen[d.neighbor](screen)
    if not adjacent then
      adjacent = screen
      while adjacent[d.reverseNeighbor](adjacent) do
        adjacent = adjacent[d.reverseNeighbor](adjacent)
      end
    end
    if adjacent ~= screen then
      win:moveToScreen(adjacent)
      hs.grid.set(win, POSITIONS.halves[d.opposite], adjacent)
      return
    end
  end

  hs.grid.set(win, targetCell, screen)
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

-- Halves (snap to half on current screen; if already at that edge, jump to the
-- adjacent screen and snap to the opposite half so it lands flush against the
-- previous screen)
modal:bind({}, "h", function()
  snapOrWrap("left")
end)
modal:bind({}, "j", function()
  snapOrWrap("down")
end)
modal:bind({}, "k", function()
  snapOrWrap("up")
end)
modal:bind({}, "l", function()
  snapOrWrap("right")
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
