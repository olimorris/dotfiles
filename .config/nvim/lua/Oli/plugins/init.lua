return {
  "nvim-lua/plenary.nvim", -- Required dependency for many plugins. Super useful Lua functions
  {
    "NvChad/nvim-colorizer.lua", -- Highlight hex and rgb colors within Neovim
    cmd = "ColorizerToggle",
    config = {
      filetypes = {
        "css",
        eruby = { mode = "foreground" },
        html = { mode = "foreground" },
        "lua",
        "javascript",
        "vue",
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim", -- Show indentation lines
    config = {
      use_treesitter = true,
      show_first_indent_level = false,
      show_trailing_blankline_indent = false,

      -- filetype_exclude = filetypes_to_exclude,
      buftype_exclude = { "terminal", "nofile" },
    },
  },
  {
    "folke/todo-comments.nvim", -- Highlight and search for todo comments within the codebase
    config = {
      signs = false,
      highlight = {
        keyword = "bg",
      },
      keywords = {
        FIX = { icon = " " }, -- Custom fix icon
        PERF = { color = "perf" },
      },
      colors = {
        perf = { "TodoTest" },
        test = { "TodoTest" },
      },
    },
  },
  {
    "j-hui/fidget.nvim", -- Display LSP status messages in a floating window
    config = {
      text = {
        spinner = "line",
        done = "",
      },
      window = {
        blend = 0,
      },
      sources = {
        ["null-ls"] = {
          ignore = true, -- Ignore annoying code action prompts
        },
      },
    },
  },
  "tpope/vim-sleuth", -- Automatically detects which indents should be used in the current buffer
  "fedepujol/move.nvim", -- Move lines and blocks
  {
    "kylechui/nvim-surround", -- Use vim commands to surround text, tags with brackets, parenthesis etc
    config = true,
  },
  {
    "danymat/neogen", -- Annotation generator
    config = {
      snippet_engine = "luasnip",
    },
  },
  {
    "numToStr/Comment.nvim", -- Comment out lines with gcc
    config = true,
  },
  {
    "ThePrimeagen/refactoring.nvim", -- Refactor code like Martin Fowler
    config = true
  },
  {
    "phaazon/hop.nvim", -- Speedily navigate anywhere in a buffer
    config = true,
  },
  {
    "cshuaimin/ssr.nvim", -- Advanced search and replace using Treesitter
    lazy = true,
    config = {
      keymaps = {
        replace_all = "<C-CR>",
      },
    },
  },
  {
    "nvim-treesitter/playground", -- View Treesitter definitions
    cmd = { "TSPlaygroundToggle", "TSHighlightCapturesUnderCursor" },
  },
  {
    "stevearc/overseer.nvim", -- Task runner and job management
    lazy = true,
    config = {
      component_aliases = {
        default_neotest = {
          "on_output_summarize",
          "on_exit_set_status",
          "on_complete_dispose",
        },
      },
    },
  },
  {
    "ahmedkhalf/project.nvim", -- Automatically set the cwd to the project root
    config = function()
      require("project_nvim").setup({
        ignore_lsp = { "efm", "null-ls" },
        patterns = { "Gemfile" },
      })
      require("telescope").load_extension("projects")
    end,
  },
  {
    "kevinhwang91/nvim-bqf", -- Better quickfix window,
    ft = "qf",
  },
  {
    "nathom/tmux.nvim", -- Navigate Tmux panes inside of neovim
    enabled = function() return os.getenv("TMUX") end,
  },
  {
    "dstein64/vim-startuptime", -- Profile your Neovim startup time
    cmd = "StartupTime",
    config = function()
      vim.g.startuptime_tries = 15
      vim.g.startuptime_exe_args = { "+let g:auto_session_enabled = 0" }
    end,
  },
}
