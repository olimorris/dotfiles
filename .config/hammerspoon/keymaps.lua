-- The hyperkey is mapped to caps lock
local hyper = { "cmd", "alt", "ctrl" }

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
  g = "Google Chrome",
  m = "HEY", -- Mail
  n = "Bear", -- Notes
  o = "Notion", -- Life OS
  p = "1Password",
  r = "Reeder",
  t = "kitty", -- Terminal
  w = "word",
  z = "Todoist",
}

local LaunchOrToggle = function(key, app_name, app_filename)
  hs.hotkey.bind(hyper, key, function()
    local app = hs.application.find(app_name)
    print(app)
    -- Toggle - show
    local awin = nil
    if app then awin = app:mainWindow() end
    -- Toggle - hide
    if awin and app and app:isFrontmost() then
      app:hide()
    else
      -- Launch
      if app_filename then return hs.application.launchOrFocus(app_filename) end

      app = hs.application.find(app_name)

      hs.application.launchOrFocus(app_name)
      app.setFrontmost(app)
      app.activate(app)
    end
  end)
end

for key, app_name in pairs(apps) do
  if type(app_name) == "table" then
    LaunchOrToggle(key, app_name[1], app_name[2])
  else
    LaunchOrToggle(key, app_name)
  end
end
