return {
  {
    "sindrets/diffview.nvim",
    event = "VeryLazy",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
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
    init = function()
      require("legendary").keymaps({
        {
          "zR",
          function()
            require("ufo").openAllFolds()
          end,
          description = "Open all folds",
        },
        {
          "zM",
          function()
            require("ufo").closeAllFolds()
          end,
          description = "Close all folds",
        },
      })
    end,
  },
  {
    "stevearc/oil.nvim", -- File manager
    opts = {
      default_file_explorer = false,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      float = {
        border = "none",
      },
      is_always_hidden = function(name, bufnr)
        return name == ".."
      end,
      keymaps = {
        ["<C-c>"] = false,
        ["<C-s>"] = "actions.save",
        ["q"] = "actions.close",
        [">"] = "actions.toggle_hidden",
        ["<C-y>"] = "actions.copy_entry_path",
        ["gd"] = {
          desc = "Toggle detail view",
          callback = function()
            local oil = require("oil")
            local config = require("oil.config")
            if #config.columns == 1 then
              oil.set_columns({ "icon", "permissions", "size", "mtime" })
            else
              oil.set_columns({ "icon" })
            end
          end,
        },
      },
      buf_options = {
        buflisted = false,
      },
    },
    init = function()
      require("legendary").keymaps({
        {
          "_",
          function()
            require("oil").toggle_float(vim.fn.getcwd())
          end,
          description = "Open File Explorer",
        },
        {
          "-",
          function()
            require("oil").toggle_float()
          end,
          description = "Open File Explorer to current file",
        },
      })
    end,
  },
  {
    "stevearc/aerial.nvim", -- Toggled list of classes, methods etc in current file
    opts = {
      attach_mode = "global",
      close_on_select = true,
      layout = {
        min_width = 30,
        default_direction = "prefer_right",
      },
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
    },
    init = function()
      require("legendary").keymaps({
        {
          "<C-t>",
          function()
            require("aerial").toggle()
          end,
          mode = { "n", "x", "o" },
          description = "Aerial toggle",
        },
      })
    end,
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
