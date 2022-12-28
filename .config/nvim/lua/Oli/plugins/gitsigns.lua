local M = {
  "lewis6991/gitsigns.nvim", -- Git signs in the sign column
}

function M.config()
  require("gitsigns").setup({
    keymaps = {}, -- Do not use the default mappings
    signs = {
      add = { hl = "GitSignsAdd", text = "+" },
      change = { hl = "GitSignsChange", text = "~" },
      delete = { hl = "GitSignsDelete", text = "-" },
      topdelete = { hl = "GitSignsDelete", text = "-" },
      changedelete = { hl = "GitSignsChange", text = "-" },
    },
  })
end

return M
