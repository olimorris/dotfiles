local M = {
  "utilyre/barbecue.nvim", -- VS Code like path in winbar
  dependencies = {
    "neovim/nvim-lspconfig",
    {
      "SmiteshP/nvim-navic", -- Winbar component showing current code context
      opts = {
        highlight = false,
        separator = "  ",
        icons = {
          File = " ",
          Module = " ",
          Namespace = " ",
          Package = " ",
          Class = " ",
          Method = " ",
          Property = " ",
          Field = " ",
          Constructor = " ",
          Enum = " ",
          Interface = " ",
          Function = " ",
          Variable = " ",
          Constant = " ",
          String = " ",
          Number = " ",
          Boolean = " ",
          Array = " ",
          Object = " ",
          Key = " ",
          Null = " ",
          EnumMember = " ",
          Struct = " ",
          Event = " ",
          Operator = " ",
          TypeParameter = " ",
        },
      },
    },
  },
  init = function()
    require("legendary").commands({
      {
        ":Barbecue toggle",
        description = "Toggle Barbecue's winbar",
      },
    })
  end,
}

function M.load()
  local colors = require("onedarkpro.helpers").get_colors()

  require("barbecue").setup({
    exclude_filetypes = { "netrw", "toggleterm" },
    symbols = {
      separator = "",
      ellipsis = "",
    },
    modifiers = {
      dirname = ":~:.:s?.config/nvim/lua?Neovim?",
    },
    theme = {
      normal = { fg = colors.breadcrumbs, italic = true },
      ellipsis = { fg = colors.breadcrumbs },
      separator = { fg = colors.breadcrumbs },
      modified = { fg = colors.red },
      dirname = { fg = colors.breadcrumbs, italic = true },
      basename = { fg = colors.breadcrumbs, italic = true, bold = false },
      context = { fg = colors.breadcrumbs, italic = true },
    },
  })
end

function M.config() M.load() end

return M
