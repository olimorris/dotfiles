local ok, legendary = om.safe_require("legendary")
if not ok then return end

legendary.setup({
  select_prompt = "Legendary",
  include_builtin = false,
  include_legendary_cmds = false,
  which_key = { auto_register = false },

  keymaps = require(config_namespace .. ".core.keymaps").default_keymaps(),
  autocmds = require(config_namespace .. ".core.autocmds").default_autocmds(),
  commands = require(config_namespace .. ".core.commands").default_commands(),
})
