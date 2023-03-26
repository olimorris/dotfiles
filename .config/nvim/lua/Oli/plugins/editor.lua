return {
  {
    --TODO: Add commands and keymaps
    "mfussenegger/nvim-jdtls", -- Extensions for nicer Java development in Neovim
    ft = "java",
    init = function()
      require("legendary").commands({
        itemgroup = "Java",
        icon = "",
        description = "Java functionality...",
        commands = {
          {
            "JdtCompile",
            description = "Compile the current project",
          },
          {
            "JdtUpdateConfig",
            description = "Update the configuration of the current project",
          },
        },
      })
      require("legendary").keymaps({
        itemgroup = "Java",
        keymaps = {
          {
            "<LocalLeader>o",
            function() require("jdtls").organize_imports() end,
            description = "Organize imports",
            { noremap = true, silent = true },
          },
          -- TODO: add keymaps for extracting variables and constants:
          --  https://github.com/mfussenegger/nvim-jdtls#usage
        },
      })
    end,
  },
  {
    "kevinhwang91/nvim-ufo", -- Better folds in Neovim
    dependencies = "kevinhwang91/promise-async",
    init = function()
      require("legendary").keymaps({
        {
          itemgroup = "Folds",
          icon = "",
          description = "Folding functionality...",
          keymaps = {
            {
              "zR",
              function() require("ufo").openAllFolds() end,
              description = "Open fold",
              { noremap = true, silent = true },
            },
            {
              "zM",
              function() require("ufo").closeAllFolds() end,
              description = "Close fold",
              { noremap = true, silent = true },
            },
          },
        },
      })
    end,
  },
  {
    "stevearc/oil.nvim", -- File manager
    init = function()
      require("legendary").keymaps({
        {
          itemgroup = "Oil",
          icon = "",
          description = "Filetree functionality...",
          keymaps = {
            { "-", "<cmd>Oil --float .<CR>", description = "Open File Explorer" },
            { "_", "<cmd>Oil --float<CR>", description = "Open File Explorer to current file" },
            -- {
            --   "<C-s>",
            --   "<cmd>require('oil').save()<CR>",
            --   description = "Save work tree changes",
            --   opts = { filetype = "Oil" },
            -- },
          },
        },
      })
    end,
    opts = {
      keymaps = {
        ["<C-c>"] = false,
        ["<C-s>"] = "actions.save",
        ["q"] = "actions.close",
        [">"] = "actions.toggle_hidden",
      },
      buf_options = {
        buflisted = false,
      },
      skip_confirm_for_simple_edits = true,
      float = {
        border = "single",
        win_options = {
          winblend = 0,
        },
      },
    },
  },
  {
    "stevearc/aerial.nvim", -- Toggled list of classes, methods etc in current file
    cmd = "AerialToggle",
    init = function()
      require("legendary").keymaps({
        { "<C-t>", "<cmd>AerialToggle<CR>", description = "Aerial" },
      })
    end,
    opts = {
      backends = {
        ["_"] = { "lsp", "treesitter", "markdown" },
        ruby = { "treesitter" },
      },
      close_on_select = true,
      layout = {
        min_width = 30,
        default_direction = "prefer_left",
      },
    },
  },
  {
    "phaazon/hop.nvim", -- Speedily navigate anywhere in a buffer
    keys = { "f", "F", "t", "T", "s", "S" },
    init = function()
      local directions = require("hop.hint").HintDirection
      require("legendary").keymaps({
        {
          "f",
          function()
            return require("hop").hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true })
          end,
          hide = true,
          description = "Hop",
          mode = { "n", "o" },
        },
        {
          "F",
          function()
            return require("hop").hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true })
          end,
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
    opts = {
      keymaps = {
        replace_all = "<C-CR>",
      },
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
    opts = {
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
    "ahmedkhalf/project.nvim", -- Automatically set the cwd to the project root
    name = "project_nvim",
    opts = {
      ignore_lsp = { "efm", "null-ls" },
      patterns = { "Gemfile" },
    },
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
    opts = {
      snippet_engine = "luasnip",
    },
  },
}
