-- [[ Global Settings ]] ------------------------------------------------------
Hyper = { "cmd", "alt", "ctrl" }

hs.automaticallyCheckForUpdates(true)
hs.menuIcon(true)
hs.dockIcon(false)

-- [[ Reload Configuration ]] -------------------------------------------------
local notify = function()
  hs.notify.new({ title = "Hammerspoon", informativeText = "Config loaded" }):send()
end
hs.hotkey.bind(Hyper, "0", function()
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

-- Reload the config every time it changes
hs.pathwatcher.new(os.getenv("HOME") .. "/.dotfiles/.config/hammerspoon/", reload_config):start()

-- [[ Modules ]] --------------------------------------------------------------
require("apple-music-spotify-redirect")
require("keymaps")
require("windows")
require("zoom-killer")
require("Spoons")
