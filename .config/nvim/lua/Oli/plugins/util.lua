return {
  "nvim-lua/plenary.nvim", -- Required dependency for many plugins. Super useful Lua functions
  {
    "mrjones2014/legendary.nvim", -- A command palette for keymaps, commands and autocmds
    branch = "mrj/256/additional-keymap-filters",
    lazy = false, -- Never lazy load this
    priority = 900,
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
    opts = {
      select_prompt = "Legendary",
      include_builtin = false,
      include_legendary_cmds = false,
      which_key = { auto_register = false },
    },
  },
  {
    "akinsho/nvim-toggleterm.lua", -- Easily toggle and position the terminal
    cmd = "ToggleTerm",
    init = function()
      require("legendary").keymaps({
        { "<C-x>", "<cmd>ToggleTerm<CR>", description = "Toggleterm", mode = { "n", "t" } },
      })
    end,
    config = {
      direction = "float",
      float_opts = {
        border = "single",
        height = function() return math.floor(0.9 * vim.fn.winheight("%")) end,
        -- width = function()
        --   return math.floor(0.9 * vim.fn.winwidth("%"))
        -- end,
        highlights = {
          background = "ToggleTerm",
          border = "ToggleTermBorder",
        },
      },
      -- direction = "horizontal",
      -- size = 8,
      -- shade_terminals = true,
      shading_factor = 3, -- Match our background
      hide_numbers = true,
      close_on_exit = true,
      start_in_insert = true,
    },
  },
  {
    "olimorris/persisted.nvim", -- Session management
    lazy = true,
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
              function() vim.cmd([[Telescope persisted]]) end,
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
              ":SessionDelete",
              description = "Delete the current session",
            },
          },
        },
      })
    end,
    opts = {
      save_dir = Sessiondir .. "/",
      branch_separator = "@@",
      use_git_branch = true,
      silent = true,
      should_autosave = function()
        if vim.bo.filetype == "alpha" then return false end
        return true
      end,
      telescope = {
        before_source = function()
          vim.api.nvim_input("<ESC>:%bd!<CR>")
          require("persisted").stop()
        end,
      },
    },
  },
  {
    "kevinhwang91/nvim-bqf", -- Better quickfix window,
    ft = "qf",
  },
  {
    "nathom/tmux.nvim", -- Navigate Tmux panes inside of neovim
    enabled = function() return os.getenv("TMUX") end,
    init = function()
      require("legendary").keymaps({
        {
          "<C-k>",
          "<cmd>lua require('tmux').move_up()<CR>",
          description = "Tmux: Move up",
        },
        {
          "<C-j>",
          "<cmd>lua require('tmux').move_down()<CR>",
          description = "Tmux: Move down",
        },
        {
          "<C-h>",
          "<cmd>lua require('tmux').move_left()<CR>",
          description = "Tmux: Move left",
        },
        {
          "<C-l>",
          "<cmd>lua require('tmux').move_right()<CR>",
          description = "Tmux: Move right",
        },
      })
    end,
  },
  {
    "dstein64/vim-startuptime", -- Profile your Neovim startup time
    cmd = "StartupTime",
    init = function()
      require("legendary").commands({
        {
          ":StartupTime",
          description = "Profile Neovim's startup time",
        },
      })
    end,
    config = function()
      vim.g.startuptime_tries = 15
      vim.g.startuptime_exe_args = { "+let g:auto_session_enabled = 0" }
    end,
  },
}
