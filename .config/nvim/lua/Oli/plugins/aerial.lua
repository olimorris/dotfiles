local M = {
  "stevearc/aerial.nvim", -- Toggled list of classes, methods etc in current file
  cmd = "AerialToggle",
  init = function()
    require("legendary").keymaps({
      { "<C-t>", "<cmd>AerialToggle<CR>", description = "Aerial" },
    })
  end,
  config = {
    backends = {
      ["_"] = { "treesitter", "lsp", "markdown" },
      ruby = { "treesitter" },
    },
    close_on_select = true,
    layout = {
      min_width = 30,
      default_direction = "prefer_left",
    },
  },
}

return M
