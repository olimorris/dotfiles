return {
  "nvim-lua/plenary.nvim", -- Required dependency for many plugins. Super useful Lua functions
  {
    "mrjones2014/legendary.nvim", -- A command palette for keymaps, commands and autocmds
    priority = 10000,
    lazy = false,
    dependencies = "kkharji/sqlite.lua",
    init = function()
      require("legendary").keymaps({
        {
          "<C-p>",
          require("legendary").find,
          hide = true,
          description = "Open Legendary",
          mode = { "n", "v" },
        },
      })
    end,
    config = function()
      require("legendary").setup({
        select_prompt = "Legendary",
        include_builtin = false,
        extensions = {
          codecompanion = false,
          lazy_nvim = false,
          which_key = false,
        },
        -- Load these with the plugin to ensure they are loaded before any Neovim events
        autocmds = require("config.autocmds"),
      })
    end,
  },
  {
    "olimorris/persisted.nvim", -- Session management
    lazy = true,
    opts = {
      save_dir = Sessiondir .. "/",
      use_git_branch = true,
      autosave = true,
      -- autoload = true,
      -- allowed_dirs = {
      --   "~/Code",
      -- },
      -- on_autoload_no_session = function()
      --   return vim.notify("No session found", vim.log.levels.WARN)
      -- end,
      should_save = function()
        local excluded_filetypes = {
          "alpha",
          "oil",
          "lazy",
          "",
        }

        for _, filetype in ipairs(excluded_filetypes) do
          if vim.bo.filetype == filetype then
            return false
          end
        end

        return true
      end,
    },
    init = function()
      require("legendary").keymaps({
        {
          itemgroup = "Persisted",
          icon = "",
          description = "Session management...",
          keymaps = {
            {
              "<Leader>s",
              '<cmd>lua require("persisted").toggle()<CR>',
              description = "Toggle a session",
              opts = { silent = true },
            },
          },
        },
      })
      require("legendary").commands({
        {
          itemgroup = "Persisted",
          commands = {
            {
              ":Sessions",
              function()
                vim.cmd([[Telescope persisted]])
              end,
              description = "List sessions",
            },
            {
              ":SessionSave",
              description = "Save the session",
            },
            {
              ":SessionStart",
              description = "Start a session",
            },
            {
              ":SessionStop",
              description = "Stop the current session",
            },
            {
              ":SessionLoad",
              description = "Load the last session",
            },
            {
              ":SessionDelete",
              description = "Delete the current session",
            },
          },
        },
      })
    end,
  },
  {
    "kevinhwang91/nvim-bqf", -- Better quickfix window,
    ft = "qf",
  },
  {
    "famiu/bufdelete.nvim", -- Easily close buffers whilst preserving your window layouts
    cmd = "Bdelete",
    init = function()
      require("legendary").keymaps({
        { "<C-c>", "<cmd>Bdelete<CR>", hide = true, description = "Close Buffer" }, -- bufdelete.nvim
        { "<Tab>", "<cmd>bnext<CR>", hide = true, description = "Next buffer", opts = { noremap = false } }, -- Heirline.nvim
        { "<S-Tab>", "<cmd>bprev<CR>", hide = true, description = "Previous buffer", opts = { noremap = false } }, -- Heirline.nvim
      })
    end,
  },
}
