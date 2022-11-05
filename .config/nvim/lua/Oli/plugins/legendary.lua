local ok, legendary = om.safe_require("legendary")
if not ok then return end

legendary.setup({
  include_builtin = false,
  select_prompt = "Legendary",
  keymaps = require(config_namespace .. ".core.mappings").default_keymaps(),
  autocmds = require(config_namespace .. ".core.autocmds").default_autocmds(),
  commands = require(config_namespace .. ".core.commands").default_commands(),
  auto_register_which_key = false,
})

legendary.keymaps(require(config_namespace .. ".core.mappings").plugin_keymaps())
legendary.autocmds(require(config_namespace .. ".core.autocmds").plugin_autocmds())
legendary.commands(require(config_namespace .. ".core.commands").lsp_commands())
legendary.commands(require(config_namespace .. ".core.commands").plugin_commands())
