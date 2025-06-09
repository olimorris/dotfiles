return {
  "nvim-lua/plenary.nvim", -- Required dependency for many plugins. Super useful Lua functions
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
      om.create_user_command("Sessions", "List Sessions", function()
        require("persisted").select()
      end)
    end,
  },
  {
    "kevinhwang91/nvim-bqf", -- Better quickfix window,
    ft = "qf",
  },
}
