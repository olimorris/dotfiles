local M = {
  "utilyre/barbecue.nvim", -- VS Code like path in winbar
  dependencies = {
    "neovim/nvim-lspconfig",
    "nvim_navic",
  },
}

function M.config()
  require("barbecue").setup({
    exclude_filetypes = { "netrw", "toggleterm" },
    symbols = {
      separator = "",
      ellipsis = "",
    },
    modifiers = {
      dirname = ":~:.:s?.config/nvim/lua?Neovim?",
    },
  })

  require("legendary").commands({
    {
      ":Barbecue toggle",
      description = "Toggle Barbecue's winbar",
    },
  })
end

return M
