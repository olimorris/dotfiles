return {
  "nvim-lua/plenary.nvim", -- Required dependency for many plugins. Super useful Lua functions
  {
    "mrjones2014/legendary.nvim", -- A command palette for keymaps, commands and autocmds
    priority = 10000,
    lazy = false,
    dependencies = "kkharji/sqlite.lua",
    keys = {
      {
        "<C-p>",
        function()
          require("legendary").find()
        end,
        desc = "Open Legendary",
      },
    },
    config = function()
      require("legendary").setup({
        -- select_prompt = "Legendary",
        include_builtin = false,
        extensions = {
          codecompanion = false,
          lazy_nvim = true,
          which_key = false,
        },
        -- Load these with the plugin to ensure they are loaded before any Neovim events
        autocmds = require("config.autocmds"),
      })
    end,
  },
  {
    "olimorris/persisted.nvim", -- Session management
    event = "BufReadPre",
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
      vim.api.nvim_create_user_command("Sessions", function()
        require("persisted").select()
      end, {
        desc = "List Sessions",
      })
    end,
  },
  {
    "kevinhwang91/nvim-bqf", -- Better quickfix window,
    ft = "qf",
  },
}
