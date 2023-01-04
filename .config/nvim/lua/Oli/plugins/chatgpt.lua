local M = {
  "jackmort/chatgpt.nvim", -- AI programming
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  cmd = { "ChatGPT", "ChatGPTActAs", "ChatGPTEditWithInstructions" },
  init = function()
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
          },
        },
      },
    })
  end,
  config = {
    welcome_message = "",
    answer_sign = "",
    question_sign = "",
    chat_layout = {
      size = {
        height = "85%",
        width = "85%",
      },
    },
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
    keymaps = {
      close = { "<C-c>", "<Esc>" },
      yank_last = "<C-y>",
      scroll_up = "<C-k>",
      scroll_down = "<C-j>",
      toggle_settings = "<C-o>",
      new_session = "<C-n>",
      cycle_windows = "<Tab>",
    },
  },
}

return M
