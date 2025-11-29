-- [[ Global Settings ]] ------------------------------------------------------
Hyper = { "cmd", "alt", "ctrl" }

-- [[ Keymaps ]] --------------------------------------------------------------
hs.hotkey.bind(Hyper, "0", function()
  hs.notify
    .new({
      title = "Hammerspoon",
      informativeText = "Config loaded",
      withdrawAfter = 2,
    })
    :send()
  hs.reload()
end)

-- [[ General Settings ]] -----------------------------------------------------
local host = require("hs.host")
local name = host.localizedName()
OnPersonal = (name:find("AAGB") == nil)

hs.automaticallyCheckForUpdates(true)
hs.menuIcon(true)
hs.dockIcon(false)

-- [[ Modules ]] --------------------------------------------------------------
hs.grid.setGrid("6x4")
hs.grid.setMargins("0x0")

require("Spoons")
require("keymaps")
require("layout")
-- require("paper")
require("windows")

-- [[ Watchers ]] -------------------------------------------------------------
hs.pathwatcher
  .new(os.getenv("HOME") .. "/.config/hammerspoon/", function(files)
    hs.reload()
    hs.notify
      .new({
        title = "Hammerspoon",
        informativeText = "Config loaded",
        withdrawAfter = 10,
      })
      :send()
  end)
  :start()
