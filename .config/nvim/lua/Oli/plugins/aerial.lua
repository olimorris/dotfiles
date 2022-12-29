local M = {
  "stevearc/aerial.nvim", -- Toggled list of classes, methods etc in current file
}

function M.init()
  require("legendary").keymaps({
    { "<C-t>", "<cmd>AerialToggle<CR>", description = "Aerial" },
  })
end

function M.config()
  require("telescope").load_extension("aerial")

  require("aerial").setup({
    backends = {
      ["_"] = { "treesitter", "lsp", "markdown" },
      ruby = { "treesitter" },
    },
    close_on_select = true,
    layout = {
      min_width = 30,
      default_direction = "prefer_left",
    },
  })
end

return M
