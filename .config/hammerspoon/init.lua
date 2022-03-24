--------------------------------- RELOAD CONFIG --------------------------------
local hyper = { "cmd", "alt", "ctrl", "shift" }
local notify = function()
  hs.notify.new({ title = "Hammerspoon", informativeText = "Config loaded" }):send()
end

-- Use 0 to reload the configuration
hs.hotkey.bind(hyper, "0", function()
  notify()
  hs.reload()
end)

local function reload_config(files)
  local doReload = false
  for _, file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    notify()
    hs.reload()
  end
end

-- reload the config every time it changes
local config_watcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.config/hammerspoon/", reload_config)
config_watcher:start()

------------------------------------ MODULES -----------------------------------
require("keymaps")
require("zoom-killer")
