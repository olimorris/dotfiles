return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      styles = {
        lazygit = {
          width = 0,
          height = 0,
        },
      },
      bigfile = { enabled = false },
      git = { enabled = false },
      gitbrowse = { enabled = false },
      lazygit = {
        theme = {
          [241] = { fg = "Special" },
          activeBorderColor = { fg = "String", bold = true },
          cherryPickedCommitBgColor = { fg = "Identifier" },
          cherryPickedCommitFgColor = { fg = "Function" },
          defaultFgColor = { fg = "Normal" },
          inactiveBorderColor = { fg = "FloatBorder" },
          optionsTextColor = { fg = "Function" },
          searchingActiveBorderColor = { fg = "String", bold = true },
          selectedLineBgColor = { bg = "Visual" }, -- set to `default` to have no background colour
          unstagedChangesColor = { fg = "DiagnosticError" },
        },
      },
      quickfile = { enabled = false },
      statuscolumn = { enabled = false },
      toggle = { enabled = false },
      win = { enabled = false },
    },
    init = function(config)
      local snacks = require("snacks")

      local keymaps = {
        {
          "<C-c>",
          function()
            snacks.bufdelete()
          end,
          hide = true,
          description = "Close Buffer",
        },
        {
          "<C-x>",
          function()
            snacks.terminal.toggle()
          end,
          description = "Open terminal",
          mode = { "n", "t" },
        },
        {
          "<Esc>",
          "<C-\\><C-n>",
          description = "Escape means escape in the terminal",
          hide = true,
          mode = { "t" },
          opts = { nowait = true },
        },
      }

      for _, direction in ipairs({ "h", "j", "k", "l" }) do
        table.insert(keymaps, {
          "<C-" .. direction .. ">",
          "<C-" .. direction .. ">",
          description = "Navigate in direction " .. direction,
          mode = { "t" },
          opts = { nowait = true },
        })
      end

      require("legendary").keymaps(keymaps)
      require("legendary").commands({
        {
          "LazyGit",
          function()
            snacks.lazygit()
          end,
          description = "Open LazyGit in a floating window",
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
            -- Stop me being dumb and opening a file explorer in openai.nvim
            if vim.bo.buftype ~= "acwrite" then
              require("oil").toggle_float(vim.fn.getcwd())
            end
          end,
          description = "Open File Explorer",
        },
        {
          "-",
          function()
            -- Stop me being dumb and opening a file explorer in openai.nvim
            if vim.bo.buftype ~= "acwrite" then
              require("oil").toggle_float()
            end
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
}
