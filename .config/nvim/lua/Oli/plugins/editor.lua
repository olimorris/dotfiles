return {
  {
    "cameron-wags/rainbow_csv.nvim",
    config = true,
    ft = {
      "csv",
      "tsv",
      "csv_semicolon",
      "csv_whitespace",
      "csv_pipe",
      "rfc_csv",
      "rfc_semicolon",
    },
    cmd = {
      "RainbowDelim",
      "RainbowDelimSimple",
      "RainbowDelimQuoted",
      "RainbowMultiDelim",
    },
  },
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
      float = {
        border = "none",
      },
      skip_confirm_for_simple_edits = true,
    },
    init = function()
      require("legendary").keymaps({
        {
          itemgroup = "Oil",
          icon = "",
          description = "Filetree functionality...",
          keymaps = {
            { "-", function() require("oil").toggle_float(".") end, description = "Open File Explorer" },
            { "_", function() require("oil").toggle_float() end, description = "Open File Explorer to current file" },
          },
        },
      })
    end,
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
        default_direction = "prefer_right",
      },
    },
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          -- default options: exact mode, multi window, all directions, with a backdrop
          require("flash").jump()
        end,
      },
      {
        "S",
        mode = { "o", "x" },
        function() require("flash").treesitter() end,
      },
    },
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
    opts = {
      ignore_lsp = { "efm", "null-ls" },
      patterns = { "Gemfile" },
    },
    config = function(_, opts) require("project_nvim").setup(opts) end,
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
