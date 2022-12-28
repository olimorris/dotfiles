local M = {
  "zbirenbaum/copilot.lua", -- AI programming
  event = "InsertEnter",
}

function M.config()
  require("copilot").setup({
    panel = {
      auto_refresh = true,
    },
    suggestion = {
      auto_trigger = true, -- Suggest as we start typing
      keymap = {
        accept_word = "<C-l>",
        accept_line = "<C-j>",
      },
    },
  })
end

return M
