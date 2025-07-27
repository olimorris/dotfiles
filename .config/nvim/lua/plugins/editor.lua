return {
  {
    "kevinhwang91/nvim-ufo", -- Better folds in Neovim
    dependencies = "kevinhwang91/promise-async",
    keys = {
      {
        "zR",
        function()
          require("ufo").openAllFolds()
        end,
        desc = "Open all folds",
      },
      {
        "zM",
        function()
          require("ufo").closeAllFolds()
        end,
        desc = "Close all folds",
      },
    },
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
    keys = {
      {
        "_",
        function()
          require("oil").toggle_float(vim.fn.getcwd())
        end,
        desc = "Oil.nvim: Open File Explorer",
      },
      {
        "-",
        function()
          require("oil").toggle_float()
        end,
        desc = "Oil.nvim: Open File Explorer to current file",
      },
    },
  },
  {
    "bassamsdata/namu.nvim",
    keys = {
      {
        "<C-t>",
        function()
          require("namu.namu_symbols").show()
        end,
        mode = { "n", "x", "o" },
        desc = "Show symbols in current file",
      },
      {
        "<C-e>",
        function()
          require("namu.namu_workspace").show()
        end,
        mode = { "n", "x", "o" },
        desc = "Show symbols in workspace",
      },
    },
    opts = {
      namu_symbols = {
        enable = true,
        options = {}, -- here you can configure namu
      },
      ui_select = { enable = false }, -- vim.ui.select() wrapper
    },
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
    -- keys = {
    --   { "<C-t>", "<cmd>AerialToggle<CR>", mode = { "n", "x", "o" }, desc = "Aerial Toggle" },
    -- },
  },
  {
    "folke/todo-comments.nvim", -- Highlight and search for todo comments within the codebase
    event = "BufEnter",
    keys = {
      {
        "<Leader>t",
        function()
          require("snacks").picker.todo_comments()
        end,
        desc = "Todo comments",
      },
    },
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
}
