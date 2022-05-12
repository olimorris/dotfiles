local M = {}

function M.setup()
  local ok, legendary = om.safe_require("legendary")
  if not ok then
    return
  end

  if not vim.g.legendary then
    legendary.setup({
      include_builtin = false,
      keymaps = require(config_namespace .. ".core.mappings").default_keymaps(),
      commands = require(config_namespace .. ".core.commands").default_commands(),
      autocmds = require(config_namespace .. ".core.autocmds").default_autocmds(),
      auto_register_which_key = false,
    })

    legendary.bind_keymaps(require(config_namespace .. ".core.mappings").plugin_keymaps())
    legendary.bind_keymaps(require(config_namespace .. ".core.commands").plugin_commands())
  end

  vim.g.legendary = true
end

return M
