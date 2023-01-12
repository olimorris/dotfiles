local function load(name)
  local Util = require("lazy.core.util")
  for _, mod in ipairs({ config_namespace .. ".config." .. name }) do
    Util.try(function() require(mod) end, {
      msg = "Failed loading " .. mod,
      on_error = function(msg)
        local modpath = require("lazy.core.cache").find(mod)
        if modpath then Util.error(msg) end
      end,
    })
  end
end

-- load options here, before lazy init while sourcing plugin modules
-- this is needed to make sure options will be correctly applied
-- after installing missing plugins
load("options")
load("functions")

-- autocmds and keymaps can wait to load
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    load("commands")
    load("keymaps")
  end,
})

return {}
