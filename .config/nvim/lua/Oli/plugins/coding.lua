return {
  "tpope/vim-sleuth", -- Automatically detects which indents should be used in the current buffer
  {
    "kylechui/nvim-surround", -- Use vim commands to surround text, tags with brackets, parenthesis etc
    config = true,
  },
  {
    "numToStr/Comment.nvim", -- Comment out lines with gcc
    keys = { "gcc", { "gc", mode = "v" } },
    init = function()
      require("legendary").keymaps({
        {
          ":Comment",
          {
            n = "gcc",
            v = "gc",
          },
          description = "Toggle comment",
        },
      })
    end,
    config = true,
  },
  {
    "ThePrimeagen/refactoring.nvim", -- Refactor code like Martin Fowler
    lazy = true,
    init = function()
      require("legendary").keymaps({
        {
          itemgroup = "Refactoring",
          icon = "",
          description = "Refactor code",
          keymaps = {
            {
              "<LocalLeader>re",
              function() require("telescope").extensions.refactoring.refactors() end,
              description = "Open Refactoring.nvim",
              mode = { "n", "v", "x" },
            },
            {
              "<LocalLeader>rd",
              function() require("refactoring").debug.printf({ below = false }) end,
              description = "Insert Printf statement for debugging",
            },
            {
              "<LocalLeader>rv",
              {
                n = function() require("refactoring").debug.print_var({ normal = true }) end,
                x = function() require("refactoring").debug.print_var({}) end,
              },
              description = "Insert Print_Var statement for debugging",
              mode = { "n", "v" },
            },
            {
              "<LocalLeader>rc",
              function() require("refactoring").debug.cleanup() end,
              description = "Cleanup debug statements",
            },
          },
        },
      })
    end,
    config = true,
  },
  {
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
    {
      "zbirenbaum/copilot.lua", -- AI programming
      event = "InsertEnter",
      init = function()
        require("legendary").keymaps({
          {
            itemgroup = "Copilot",
            description = "AI programming",
            icon = "",
            keymaps = {
              {
                "<C-a>",
                function() require("copilot.suggestion").accept() end,
                description = "Accept suggestion",
                mode = { "i" },
                opts = { silent = true },
              },
              {
                "<C-x>",
                function() require("copilot.suggestion").dismiss() end,
                description = "Dismiss suggestion",
                mode = { "i" },
                opts = { silent = true },
              },
              {
                "<C-n>",
                function() require("copilot.suggestion").next() end,
                description = "Next suggestion",
                mode = { "i" },
                opts = { silent = true },
              },
              {
                "<C-\\>",
                function() require("copilot.panel").open() end,
                description = "Show Copilot panel",
                mode = { "n", "i" },
              },
            },
          },
        })

        require("legendary").commands({
          {
            ":CopilotToggle",
            function() require("copilot.suggestion").toggle_auto_trigger() end,
            description = "Toggle on/off for buffer",
          },
        })
      end,
      config = {
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
      },
    },
  },
}
