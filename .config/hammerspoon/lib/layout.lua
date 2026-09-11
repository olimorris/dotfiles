local util = require("lib.util")

local LAPTOP = "Retina Display"

---@param screen_type string "laptop" or "monitor"
---@return table
local function getScreen(screen_type)
  if screen_type == "laptop" then
    return util.screenMatching(LAPTOP) or hs.screen.primaryScreen()
  elseif screen_type == "monitor" then
    return util.screenNotMatching(LAPTOP) or hs.screen.primaryScreen()
  end
  return hs.screen.primaryScreen()
end

---@param app_name string
---@param grid_settings string
---@param opts table Options (focus, moveToScreen, onlyIfOpen, url)
---@return nil
local function processApp(app_name, grid_settings, opts)
  if opts.onlyIfOpen and not hs.application.get(app_name) then
    return
  end

  if opts.url then
    hs.urlevent.openURL(opts.url) -- opens in default browser, then falls through to grid it via app_name
  else
    hs.application.launchOrFocus(app_name)
  end

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
      if opts.moveToScreen == "monitor" and not util.screenNotMatching(LAPTOP) then
        final_grid_settings = util.GRID.full -- no monitor, so fill the laptop screen instead
      elseif opts.moveToScreen then
        win:moveToScreen(getScreen(opts.moveToScreen))
      end

      hs.grid.set(win, final_grid_settings)
    end

    if opts.focus then
      app:activate()
    end
  end)
end

local M = {}

---@param name string
---@param key number Hotkey to trigger the layout (1-9)
---@param layout {app: string, grid_settings: string, opts: { focus?: boolean, moveToScreen?: string, onlyIfOpen?: boolean, url?: string }}[]
---@return nil
function M.define(name, key, layout)
  hs.hotkey.bind(Hyper, tostring(key), function()
    hs.alert.show("Layout: " .. name)

    for _, app_config in ipairs(layout) do
      processApp(app_config[1], app_config[2], app_config[3] or {})
    end
  end)
end

return M
