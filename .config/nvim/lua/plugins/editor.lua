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
    end,
    keys = {
      {
        "<LocalLeader>o",
        function()
          require("jdtls").organize_imports()
        end,
        desc = "Java: Organize imports",
      },
    },
  },
  {
    "kevinhwang91/nvim-ufo", -- Better folds in Neovim
    dependencies = "kevinhwang91/promise-async",
    keys = {
      {
        "zR",
        function()
          require("ufo").openAllFolds()
        end,
        desc = "Open fold",
      },
      {
        "zM",
        function()
          require("ufo").closeAllFolds()
        end,
        desc = "Close fold",
      },
    },
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
    keys = {
      {
        "_",
        function()
          require("oil").toggle_float(".")
        end,
        desc = "Open File Explorer",
      },
      {
        "-",
        function()
          require("oil").toggle_float()
        end,
        desc = "Open File Explorer to current file",
      },
    },
  },
  {
    "stevearc/aerial.nvim", -- Toggled list of classes, methods etc in current file
    cmd = "AerialToggle",
    keys = {
      {
        "<C-t>",
        function()
          require("aerial").toggle()
        end,
        mode = { "n", "x", "o" },
        desc = "Toggle Aerial",
      },
    },
    opts = {
      attach_mode = "global",
      close_on_select = true,
      filter_kind = false,
      -- Use nvim-navic icons
      icons = {
        File = "󰈙 ",
        Module = " ",
        Namespace = "󰌗 ",
        Package = " ",
        Class = "󰌗 ",
        Method = "󰆧 ",
        Property = " ",
        Field = " ",
        Constructor = " ",
        Enum = "󰕘",
        Interface = "󰕘",
        Function = "󰊕 ",
        Variable = "󰆧 ",
        Constant = "󰏿 ",
        String = "󰀬 ",
        Number = "󰎠 ",
        Boolean = "◩ ",
        Array = "󰅪 ",
        Object = "󰅩 ",
        Key = "󰌋 ",
        Null = "󰟢 ",
        EnumMember = " ",
        Struct = "󰌗 ",
        Event = " ",
        Operator = "󰆕 ",
        TypeParameter = "󰊄 ",
      },
      layout = {
        min_width = 30,
        default_direction = "prefer_right",
      },
    },
  },
  -- {
  --   "cshuaimin/ssr.nvim", -- Advanced search and replace using Treesitter
  --   lazy = true,
  --   keys = {
  --     {
  --       "<LocalLeader>sr",
  --       function() require("ssr").open() end,
  --       desc = "Structured search and replace",
  --     },
  --   },
  --   opts = {
  --     keymaps = {
  --       replace_all = "<C-CR>",
  --     },
  --   },
  -- },
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
    config = function(_, opts)
      require("project_nvim").setup(opts)
    end,
  },
}
