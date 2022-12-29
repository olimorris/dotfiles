local M = {
  "jackmort/chatgpt.nvim", -- AI programming
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  cmd = { "ChatGPT", "ChatGPTActAs", "ChatGPTEditWithInstructions" },
}

function M.init()
  require("legendary").keymaps({
    {
      itemgroup = "ChatGPT",
      icon = "ﮧ",
      description = "Use ChatGPT to generate code",
      keymaps = {
        { "<C-a>", "<cmd>ChatGPT<CR>", description = "Ask a question..." },
      },
    },
  })
  require("legendary").commands({
    {
      itemgroup = "ChatGPT",
      commands = {
        {
          ":ChatGPTActAs",
          description = "Ask a question, acting as...",
        },
        {
          ":ChatGPTEditWithInstructions",
          description = "Open an interactive window",
        }
      },
    },
  })
end

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
