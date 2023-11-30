--------------------------------- RELOAD CONFIG --------------------------------
Hyper = { "cmd", "alt", "ctrl" }

local notify = function()
  hs.notify.new({ title = "Hammerspoon", informativeText = "Config loaded" }):send()
end

-- Use 0 to reload the configuration
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

-- reload the config every time it changes
hs.pathwatcher.new(os.getenv("HOME") .. "/.dotfiles/.config/hammerspoon/", reload_config):start()

------------------------------------ MODULES -----------------------------------
require("keymaps")
require("zoom-killer")
require("apple-music-spotify-redirect")
