local ok, legendary = om.safe_require("legendary")
if not ok then return end

legendary.setup({
  select_prompt = "Legendary",
  include_builtin = false,
  include_legendary_cmds = false,
  which_key = { auto_register = false },

  keymaps = require(config_namespace .. ".core.mappings").base_keymaps(),
  autocmds = require(config_namespace .. ".core.autocmds").base_autocmds(),
  commands = require(config_namespace .. ".core.commands").base_commands(),
})

legendary.keymaps(require(config_namespace .. ".core.mappings").plugin_keymaps())
legendary.autocmds(require(config_namespace .. ".core.autocmds").plugin_autocmds())
legendary.commands(require(config_namespace .. ".core.commands").lsp_commands())
legendary.commands(require(config_namespace .. ".core.commands").plugin_commands())
