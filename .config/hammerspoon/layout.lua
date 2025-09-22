---Focus the application if it's opened
local function focusIfLaunched(appname)
  local app = hs.application.get(appname)
  if app then
    app:activate()
  end
end

---Adjust the size of all windows of an application if opened
local function adjustWindowsOfApp(appname, gridsettings)
  local app = hs.application.get(appname)
  local wins
  if app then
    wins = app:allwindows()
  end
  if wins then
    for i, win in ipairs(wins) do
      hs.grid.set(win, gridsettings)
    end
    focusIfLaunched(appname)
  end
end

---Define a layout and assign it to a hotkey
local function defineLayout(name, key, layout)
  hs.hotkey.bind(Hyper, tostring(key), function()
    hs.alert.show("Layout: " .. name)
    for i, app in ipairs(layout) do
      adjustWindowsOfApp(app[1], app[2])
      if app[3] then
        focusIfLaunched(app[1])
      end
    end
  end)
end

-- [[ Layouts ] ---------------------------------------------------------------

defineLayout("Coding", 1, {
  { "Wezterm", "0,0 3x4" },
  { "Safari", "3,0 3x4", true },
})

defineLayout("Study", 2, {
  { "Safari", "0,0 3x4" },
  { "Notion", "3,0 3x4", true },
  { "Wezterm", "0,0 6x4" },
})
