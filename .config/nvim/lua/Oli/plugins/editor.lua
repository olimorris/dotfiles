return {
  {
    "nvim-neo-tree/neo-tree.nvim", -- File explorer
    branch = "v2.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    init = function()
      require("legendary").keymaps({
        { "<C-n>", "<cmd>Neotree toggle<CR>", hide = true, description = "Neotree: Toggle" },
        { "<C-z>", "<cmd>Neotree reveal=true toggle<CR>", hide = true, description = "Neotree: Reveal File" },
      })
    end,
    config = {
      close_if_last_window = true,
      -- git_status_async = false,
      enable_git_status = true,
      enable_diagnostics = false,
      default_component_configs = {
        icon = {
          folder_open = "",
          folder_closed = "",
          folder_empty = "ﰊ",
          default = "*",
        },
        indent = {
          with_markers = false,
        },
        modified = {
          symbol = "[+]",
          highlight = "NeoTreeModified",
        },
      },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
      window = {
        width = 30,
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
    config = {
      backends = {
        ["_"] = { "treesitter", "lsp", "markdown" },
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
    "ahmedkhalf/project.nvim", -- Automatically set the cwd to the project root
    name = "project_nvim",
    config = {
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
    config = {
      snippet_engine = "luasnip",
    },
  },
}
