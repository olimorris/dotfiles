local M = {
  "utilyre/barbecue.nvim", -- VS Code like path in winbar
  lazy = true,
  dependencies = {
    "neovim/nvim-lspconfig",
    "nvim_navic",
  },
  init = function()
    require("legendary").commands({
      {
        ":Barbecue toggle",
        description = "Toggle Barbecue's winbar",
      },
    })
  end,
  config = {
    exclude_filetypes = { "netrw", "toggleterm" },
    symbols = {
      separator = "",
      ellipsis = "",
    },
    modifiers = {
      dirname = ":~:.:s?.config/nvim/lua?Neovim?",
    },
  },
}

return M
