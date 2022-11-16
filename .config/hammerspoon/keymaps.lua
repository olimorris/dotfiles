-- The hyperkey is mapped to caps lock via Karabiner
local hyper = { "cmd", "alt", "ctrl", "shift" }

------------------------------- APP LAUNCH/TOGGLE ------------------------------
--[[
  The list of keys and apps which enable launching and toggling
  Some apps have a different process name to their name on disk. To address
  this, a table can be passed which contains the app name followed by the filename
]]
local apps = {
  b = "Safari", -- Browser
  c = { "Code", "Visual Studio Code" },
  e = "Microsoft Excel",
  f = "Finder",
  g = "Chrome",
  h = "", -- Reserved
  j = "", -- Reserved
  k = "", -- Reserved
  l = "", -- Reserved
  m = "HEY", -- Mail
  n = "Bear", -- Notes
  o = "Notion", -- Life OS
  p = "1Password",
  r = "Reeder",
  t = "kitty", -- Terminal
  z = "Todoist",
}

local launchOrToggle = function(key, app_name, app_filename)
  hs.hotkey.bind(hyper, key, function()
    app = hs.application.find(app_name)
    -- Toggle - show
    if app then awin = app:mainWindow() end
    -- Toggle - hide
    if awin and app and app:isFrontmost() then
      app:hide()
    else
      -- Launch
      if app_filename then return hs.application.launchOrFocus(app_filename) end

      local app = hs.application.find(app_name)

      hs.application.launchOrFocus(app_name)
      app.setFrontmost(app)
      app.activate(app)
    end
  end)
end

for key, app_name in pairs(apps) do
  if type(app_name) == "table" then
    launchOrToggle(key, app_name[1], app_name[2])
  else
    launchOrToggle(key, app_name)
  end
end

------------------------------- WINDOW MANAGEMENT ------------------------------

hs.window.animationDuration = 0

-- Move window to left 50%
hs.hotkey.bind(hyper, "h", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  win:moveToUnit(hs.layout.left50)
end)

-- Maximise window
hs.hotkey.bind(hyper, "j", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  win:moveToUnit(hs.layout.maximized)
end)

-- Move window to next screen
hs.hotkey.bind(hyper, "k", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  win:moveToScreen(win:screen():next())
end)

-- Move window to right 50%
hs.hotkey.bind(hyper, "l", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  win:moveToUnit(hs.layout.right50)
end)

-- Move window to left 30%
hs.hotkey.bind(hyper, "1", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  win:moveToUnit(hs.layout.left30)
end)

-- Move window to right 70%
hs.hotkey.bind(hyper, "2", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  win:moveToUnit(hs.layout.right70)
end)

------------------------------------- MOUSE ------------------------------------
hs.eventtap
  .new({ hs.eventtap.event.types.otherMouseUp }, function(event)
    local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
    if button == 3 then hs.eventtap.keyStroke({ "cmd" }, "[") end
    if button == 4 then hs.eventtap.keyStroke({ "cmd" }, "]") end
  end)
  :start()

------------------------------------ OTHERS ------------------------------------
-- bind shift+ctrl+option+l to lock screen
hs.hotkey.bind({ "alt", "ctrl", "shift" }, "L", function() hs.caffeinate.lockScreen() end)
