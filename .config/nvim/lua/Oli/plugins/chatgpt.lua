local M = {
  "jackmort/chatgpt.nvim", -- AI programming
  cmd = "ChatGPT",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
}

function M.config()
  require("chatgpt").setup({
    welcome_message = "",
    answer_sign = "",
    question_sign = "",
    chat_window = {
      win_options = {
        winblend = 0,
        winhighlight = "Normal:ChatGPTWindow,FloatBorder:FloatBorder",
      },
    },
    chat_input = {
      prompt = "   ",
      win_options = {
        winblend = 0,
        winhighlight = "Normal:ChatGPTPrompt,ChatGPTPrompt:FloatBorder",
      },
    },
  })
end

return M