---Get screen by type
---@param screen_type string "laptop" or "monitor"
---@return table Screen object
local function getScreen(screen_type)
  local screens = hs.screen.allScreens()

  if screen_type == "laptop" then
    for _, screen in ipairs(screens) do
      if screen:name():find("Retina Display") or screen == hs.screen.primaryScreen() then
        return screen
      end
    end
  elseif screen_type == "monitor" then
    for _, screen in ipairs(screens) do
      if not screen:name():find("Retina Display") then
        return screen
      end
    end
  end

  return hs.screen.primaryScreen() -- fallback
end

---Check if an external monitor is connected
---@return boolean True if external monitor is connected
local function isMonitorConnected()
  local screens = hs.screen.allScreens()
  for _, screen in ipairs(screens) do
    if not screen:name():find("Retina Display") then
      return true
    end
  end
  return false
end

---Process a single app in the layout
---@param app_name string Name of the application
---@param grid_settings string Grid settings
---@param opts table Options (focus, moveToScreen)
---@return nil
local function processApp(app_name, grid_settings, opts)
  -- Always ensure app is launched
  hs.application.launchOrFocus(app_name)

  -- Small delay to let app launch if needed
  hs.timer.doAfter(0.3, function()
    local app = hs.application.get(app_name)
    if not app then
      return
    end

    local wins = app:allWindows()
    if not wins or #wins == 0 then
      return
    end

    for _, win in ipairs(wins) do
      local final_grid_settings = grid_settings
      if opts.moveToScreen == "monitor" and not isMonitorConnected() then
        final_grid_settings = "0,0 6x4" -- Always go full screen on laptop
      elseif opts.moveToScreen then
        local target_screen = getScreen(opts.moveToScreen)
        win:moveToScreen(target_screen)
      end

      hs.grid.set(win, final_grid_settings)
    end

    if opts.focus then
      app:activate()
    end
  end)
end

---Define a layout and assign it to a hotkey
---@param name string Name of the layout
---@param key number Hotkey to trigger the layout (1-9)
---@param layout {app: string, grid_settings: string, opts: { focus?: boolean, moveToMonitor?: boolean }}[] List of applications and their grid settings
---@return nil
local function defineLayout(name, key, layout)
  hs.hotkey.bind(Hyper, tostring(key), function()
    hs.alert.show("Layout: " .. name)

    for _, app_config in ipairs(layout) do
      local app_name = app_config[1]
      local grid_settings = app_config[2]
      local opts = app_config[3] or {}

      processApp(app_name, grid_settings, opts)
    end
  end)
end

-- Watch for screen changes
hs.screen.watcher
  .new(function()
    hs.timer.doAfter(1, function() -- Delay to allow screen to stabilize
      hs.reload()
    end)
  end)
  :start()

-- [[ Layouts ] ---------------------------------------------------------------
defineLayout("Coding", 1, {
  { "WezTerm", "0,0 3x4", { focus = true, moveToScreen = "monitor" } },
  { "Safari", "3,0 3x4", { moveToScreen = "monitor" } },
})

defineLayout("Study", 2, {
  { "Spotify", "0,0 1.75x4", { moveToScreen = "monitor" } },
  { "Safari", "1.75,0 2.5x4", { focus = true, moveToScreen = "monitor" } },
  { "Notion", "4.25,0 1.75x4", { moveToScreen = "monitor" } },
  { "WezTerm", "0,0 6x4", { moveToScreen = "laptop" } },
})
