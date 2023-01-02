local M = {
  "lewis6991/gitsigns.nvim", -- Git signs in the sign column
  config = {
    keymaps = {}, -- Do not use the default mappings
    signs = {
      add = { hl = "GitSignsAdd", text = "+" },
      change = { hl = "GitSignsChange", text = "~" },
      delete = { hl = "GitSignsDelete", text = "-" },
      topdelete = { hl = "GitSignsDelete", text = "-" },
      changedelete = { hl = "GitSignsChange", text = "-" },
    },
  },
}

return M
