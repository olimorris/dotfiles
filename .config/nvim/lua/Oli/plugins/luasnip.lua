local M = {}

function M.setup()
  local ok, luasnip = om.safe_require("luasnip")
  if not ok then
    return
  end

  local types = require("luasnip.util.types")

  luasnip.config.set_config({
    history = true,
    updateevents = 'TextChanged,TextChangedI',
    region_check_events = "CursorMoved,CursorHold,InsertEnter",
    delete_check_events = "InsertLeave",
    ext_opts = {
      [types.choiceNode] = {
        passive = {
          virt_text = { { "●", "Operator" } },
          hl_group = "LuaSnipChoiceNode",
        },
      },
      [types.insertNode] = {
        active = {
          virt_text = { { "●", "Type" } },
          hl_group = "LuaSnipInsertNode",
        },
      },
    },
  })

  -- Tell Neovim about our custom snippets directory which is outside of our config
  -- Update the package.json file in this path if you add any new snippets
  vim.o.runtimepath = vim.o.runtimepath .. ",~/.dotfiles/.config/snippets"

  -- Tell LuaSnip that we want our snippets to be like VSCode
  require("luasnip.loaders.from_vscode").lazy_load()
end

function M.snippets()
  return nil
end

return M

