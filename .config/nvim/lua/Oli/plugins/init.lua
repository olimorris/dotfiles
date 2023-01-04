return {
  "nvim-lua/plenary.nvim", -- Required dependency for many plugins. Super useful Lua functions
  "tpope/vim-sleuth", -- Automatically detects which indents should be used in the current buffer
  {
    "NvChad/nvim-colorizer.lua", -- Highlight hex and rgb colors within Neovim
    cmd = "ColorizerToggle",
    init = function()
      require("legendary").commands({
        {
          ":ColorizerToggle",
          description = "Colorizer toggle",
        },
      })
    end,
    config = {
      filetypes = {
        "css",
        eruby = { mode = "foreground" },
        html = { mode = "foreground" },
        "lua",
        "javascript",
        "vue",
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim", -- Show indentation lines
    config = {
      use_treesitter = true,
      show_first_indent_level = false,
      show_trailing_blankline_indent = false,

      -- filetype_exclude = filetypes_to_exclude,
      buftype_exclude = { "terminal", "nofile" },
    },
  },
  {
    "folke/todo-comments.nvim", -- Highlight and search for todo comments within the codebase
    event = "BufEnter",
    init = function()
      require("legendary").keymaps({
        { "<Leader>t", "<cmd>TodoTelescope<CR>", description = "Todo comments" },
      })
    end,
    config = {
      signs = false,
      highlight = {
        keyword = "bg",
      },
      keywords = {
        FIX = { icon = " " }, -- Custom fix icon
      },
    },
  },
  {
    "j-hui/fidget.nvim", -- Display LSP status messages in a floating window
    config = {
      text = {
        spinner = "line",
        done = "",
      },
      window = {
        blend = 0,
      },
      sources = {
        ["null-ls"] = {
          ignore = true, -- Ignore annoying code action prompts
        },
      },
    },
  },
  {
    "fedepujol/move.nvim", -- Move lines and blocks
    init = function()
      require("legendary").keymaps({
        {
          "<A-j>",
          { n = "<cmd>MoveLine(1)<CR>", x = ":MoveBlock(1)<CR>" },
          hide = true,
          description = "Move text down",
          opts = { silent = true },
        },
        {
          "<A-k>",
          { n = "<cmd>MoveLine(-1)<CR>", x = ":MoveBlock(-1)<CR>" },
          hide = true,
          description = "Move text up",
          opts = { silent = true },
        },
        {
          "<A-h>",
          { n = "<cmd>MoveHChar(-1)<CR>", x = ":MoveHBlock(-1)<CR>" },
          hide = true,
          description = "Move text left",
          opts = { silent = true },
        },
        {
          "<A-l>",
          { n = "<cmd>MoveHChar(1)<CR>", x = ":MoveHBlock(1)<CR>" },
          hide = true,
          description = "Move text right",
          opts = { silent = true },
        },
      })
    end,
  },
  {
    "kylechui/nvim-surround", -- Use vim commands to surround text, tags with brackets, parenthesis etc
    config = true,
  },
  {
    "danymat/neogen", -- Annotation generator
    cmd = "Neogen",
    init = function()
      require("legendary").commands({
        {
          ":Neogen",
          description = "Generate annotation",
        },
      })
    end,
    config = {
      snippet_engine = "luasnip",
    },
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
    "phaazon/hop.nvim", -- Speedily navigate anywhere in a buffer
    keys = { "f", "F", "t", "T", "s", "S" },
    init = function()
      local directions = require("hop.hint").HintDirection
      require("legendary").keymaps({
        {
          "f",
          function() return require("hop").hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true }) end,
          hide = true,
          description = "Hop",
          mode = { "n", "o" },
        },
        {
          "F",
          function() return require("hop").hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true }) end,
          hide = true,
          description = "Hop",
          mode = { "n", "o" },
        },
        {
          "t",
          function()
            return require("hop").hint_char1({
              direction = directions.AFTER_CURSOR,
              current_line_only = true,
              hint_offset = -1,
            })
          end,
          hide = true,
          description = "Hop",
          mode = { "n", "o" },
        },
        {
          "T",
          function()
            return require("hop").hint_char1({
              direction = directions.BEFORE_CURSOR,
              current_line_only = true,
              hint_offset = 1,
            })
          end,
          hide = true,
          description = "Hop",
          mode = { "n", "o" },
        },
        {
          "s",
          function() return require("hop").hint_char1({ direction = directions.AFTER_CURSOR }) end,
          hide = true,
          description = "Hop",
          mode = { "n", "o" },
        },
        {
          "S",
          function() return require("hop").hint_char1({ direction = directions.BEFORE_CURSOR }) end,
          hide = true,
          description = "Hop",
          mode = { "n", "o" },
        },
      })
    end,
    config = true,
  },
  {
    "cshuaimin/ssr.nvim", -- Advanced search and replace using Treesitter
    lazy = true,
    init = function()
      require("legendary").keymaps({
        itemgroup = "Find and Replace",
        keymaps = {
          {
            "<LocalLeader>sr",
            function() require("ssr").open() end,
            description = "Structured search and replace",
          },
        },
      })
    end,
    config = {
      keymaps = {
        replace_all = "<C-CR>",
      },
    },
  },
  {
    "nvim-treesitter/playground", -- View Treesitter definitions
    cmd = { "TSPlayground", "TSHighlightCapturesUnderCursor" },
    init = function()
      require("legendary").commands({
        {
          ":TSPlayground",
          description = "Treesitter Playground",
        },
      })
    end,
  },
  {
    "stevearc/overseer.nvim", -- Task runner and job management
    lazy = true,
    config = {
      component_aliases = {
        default_neotest = {
          "on_output_summarize",
          "on_exit_set_status",
          "on_complete_dispose",
        },
      },
    },
  },
  {
    "ahmedkhalf/project.nvim", -- Automatically set the cwd to the project root
    name = "project_nvim",
    config = {
      ignore_lsp = { "efm", "null-ls" },
      patterns = { "Gemfile" },
    },
  },
  {
    "kevinhwang91/nvim-bqf", -- Better quickfix window,
    ft = "qf",
  },
  {
    "nathom/tmux.nvim", -- Navigate Tmux panes inside of neovim
    enabled = function() return os.getenv("TMUX") end,
    init = function()
      require("legendary").keymaps({
        {
          "<C-k>",
          "<cmd>lua require('tmux').move_up()<CR>",
          description = "Tmux: Move up",
        },
        {
          "<C-j>",
          "<cmd>lua require('tmux').move_down()<CR>",
          description = "Tmux: Move down",
        },
        {
          "<C-h>",
          "<cmd>lua require('tmux').move_left()<CR>",
          description = "Tmux: Move left",
        },
        {
          "<C-l>",
          "<cmd>lua require('tmux').move_right()<CR>",
          description = "Tmux: Move right",
        },
      })
    end,
  },
  {
    "dstein64/vim-startuptime", -- Profile your Neovim startup time
    cmd = "StartupTime",
    init = function()
      require("legendary").commands({
        {
          ":StartupTime",
          description = "Profile Neovim's startup time",
        },
      })
    end,
    config = function()
      vim.g.startuptime_tries = 15
      vim.g.startuptime_exe_args = { "+let g:auto_session_enabled = 0" }
    end,
  },
}
