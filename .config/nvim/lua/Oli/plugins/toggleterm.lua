local M = {
  "akinsho/nvim-toggleterm.lua", -- Easily toggle and position the terminal
  cmd = "ToggleTerm",
}

function M.init()
  require("legendary").keymaps({
    { "<C-x>", "<cmd>ToggleTerm<CR>", description = "Toggleterm", mode = { "n", "t" } },
  })
end

function M.config()
  require("toggleterm").setup({
    direction = "float",
    float_opts = {
      border = "single",
      height = function() return math.floor(0.9 * vim.fn.winheight("%")) end,
      -- width = function()
      --   return math.floor(0.9 * vim.fn.winwidth("%"))
      -- end,
      highlights = {
        background = "ToggleTerm",
        border = "ToggleTermBorder",
      },
    },
    -- direction = "horizontal",
    -- size = 8,
    -- shade_terminals = true,
    shading_factor = 3, -- Match our background
    hide_numbers = true,
    close_on_exit = true,
    start_in_insert = true,
  })
end

return M
