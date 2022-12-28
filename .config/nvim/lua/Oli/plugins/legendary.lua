local M = {
  "mrjones2014/legendary.nvim", -- A command palette for keymaps, commands and autocmds
  lazy = true,
  priority = 900,
  dependencies = "kkharji/sqlite.lua",
}

function M.config()
  require("legendary").setup({
    select_prompt = "Legendary",
    include_builtin = false,
    include_legendary_cmds = false,
    which_key = { auto_register = false },

    keymaps = require(config_namespace .. ".keymaps").default_keymaps(),
    autocmds = require(config_namespace .. ".autocmds").default_autocmds(),
    commands = require(config_namespace .. ".commands").default_commands(),
  })
end

return M
