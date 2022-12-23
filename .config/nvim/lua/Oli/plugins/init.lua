require(config_namespace .. ".plugins.lazy")

local ok, lazy = om.safe_require("lazy")
if not ok then return end

-----------------------------------OPTIONS---------------------------------- {{{
local opts = {
  checker = {
    enabled = true,
    notify = false,
  },
  install = {
    colorscheme = { "onedark" },
  },
  ui = {
    icons = {
      plugin = "",
    },
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
}
---------------------------------------------------------------------------- }}}
--------------------------------PREREQUISITES------------------------------- {{{
lazy.setup({
  { "nvim-lua/plenary.nvim" }, -- Required dependency for many plugins. Super useful Lua functions
  { "antoinemadec/FixCursorHold.nvim" }, -- Fix neovim CursorHold and CursorHoldI autocmd events performance bug
  ---------------------------------------------------------------------------- }}}
  -------------------------------------UI------------------------------------- {{{
  {
    --"olimorris/onedarkpro.nvim",
    dir = "~/Code/Projects/onedarkpro.nvim",
    name = "onedarkpro",
    config = function() require(config_namespace .. ".plugins.theme") end,
  },
  {
    "mrjones2014/legendary.nvim", -- A command palette for keymaps, commands and autocmds
    dependencies = "kkharji/sqlite.lua",
    config = function() require(config_namespace .. ".plugins.legendary") end,
  },
  {
    "goolord/alpha-nvim", -- Dashboard for Neovim
    config = function() require(config_namespace .. ".plugins.dashboard") end,
  },
  {
    "rebelot/heirline.nvim", -- Statusline and bufferline
    dependencies = {
      "onedarkpro",
      "kyazdani42/nvim-web-devicons",
      "famiu/bufdelete.nvim", -- Easily close buffers whilst preserving your window layouts
    },
    config = function() require(config_namespace .. ".plugins.statusline").setup() end,
  },
  {
    "lewis6991/gitsigns.nvim", -- Git signs in the sign column
    config = function() require(config_namespace .. ".plugins.gitsigns") end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim", -- File explorer
    branch = "v2.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    config = function() require(config_namespace .. ".plugins.file_explorer") end,
  },
  {
    "NvChad/nvim-colorizer.lua", -- Highlight hex and rgb colors within Neovim
    cmd = "ColorizerToggle",
    config = function() require(config_namespace .. ".plugins.others").colorizer() end,
  },
  {
    "lukas-reineke/indent-blankline.nvim", -- Show indentation lines
    config = function() require(config_namespace .. ".plugins.others").indentline() end,
  },
  {
    "folke/todo-comments.nvim", -- Highlight and search for todo comments within the codebase
    config = function() require(config_namespace .. ".plugins.others").todo_comments() end,
  },
  {
    "utilyre/barbecue.nvim", -- VS Code like path in winbar
    dependencies = {
      "neovim/nvim-lspconfig",
      {
        "SmiteshP/nvim-navic", -- Winbar component showing current code context
        config = function() require(config_namespace .. ".plugins.others").nvim_navic() end,
      },
    },
    config = function() require(config_namespace .. ".plugins.others").barbecue() end,
  },
  {
    "j-hui/fidget.nvim", -- Display LSP status messages in a floating window
    config = function() require(config_namespace .. ".plugins.others").fidget() end,
  },

  {
    "stevearc/dressing.nvim", -- Utilises Neovim 0.6's new UI hooks to manage inputs, selects etc
    config = function() require(config_namespace .. ".plugins.others").dressing() end,
  },
  ---------------------------------------------------------------------------- }}}
  --------------------------------WRITING CODE-------------------------------- {{{
  { "tpope/vim-sleuth" }, -- Automatically detects which indents should be used in the current buffer
  {
    "kylechui/nvim-surround", -- Use vim commands to surround text, tags with brackets, parenthesis etc
    config = function() require(config_namespace .. ".plugins.others").nvim_surround() end,
  },
  {
    "danymat/neogen", -- Annotation generator
    config = function() require(config_namespace .. ".plugins.others").neogen() end,
  },
  {
    "numToStr/Comment.nvim", -- Comment out lines with gcc
    config = function() require(config_namespace .. ".plugins.others").comment() end,
  },
  {
    "fedepujol/move.nvim", -- Move lines and blocks
  },
  {
    "ThePrimeagen/refactoring.nvim", -- Refactor code like Martin Fowler
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function() require(config_namespace .. ".plugins.others").refactoring() end,
  },
  {
    "zbirenbaum/copilot.lua", -- AI programming
    event = "InsertEnter",
    config = function()
      vim.schedule(function() require(config_namespace .. ".plugins.others").copilot() end)
    end,
  },
  {
    "jackmort/chatgpt.nvim", -- AI programming
    config = function() require(config_namespace .. ".plugins.others").chatgpt() end,
    cmd = "ChatGPT",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },
  ---------------------------------------------------------------------------- }}}
  ----------------------------------SEARCHING--------------------------------- {{{
  {
    "nvim-telescope/telescope.nvim", -- Awesome fuzzy finder for everything
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim", -- Use fzf within Telescope
        build = "make",
        config = function() require("telescope").load_extension("fzf") end,
      },
      {
        "ThePrimeagen/harpoon", -- Navigate between marked files
        config = function() require("telescope").load_extension("harpoon") end,
      },
      {
        "debugloop/telescope-undo.nvim", -- Visualise undotree
        dependencies = { "nvim-telescope/telescope.nvim" },
        config = function() require("telescope").load_extension("undo") end,
      },
      {
        "nvim-telescope/telescope-frecency.nvim", -- Get frequently opened files
        dependencies = {
          "kkharji/sqlite.lua",
        },
        config = function() require("telescope").load_extension("frecency") end,
      },
      {
        "stevearc/aerial.nvim", -- Toggled list of classes, methods etc in current file
        config = function()
          require("telescope").load_extension("aerial")
          require(config_namespace .. ".plugins.others").aerial()
        end,
      },
    },
    config = function() require(config_namespace .. ".plugins.telescope") end,
  },
  {
    "phaazon/hop.nvim", -- Speedily navigate anywhere in a buffer
    config = function() require(config_namespace .. ".plugins.others").hop() end,
  },
  {
    "cshuaimin/ssr.nvim", -- Advanced search and replace using Treesitter
    lazy = true,
    config = function() require(config_namespace .. ".plugins.others").ssr() end,
  },
  ---------------------------------------------------------------------------- }}}
  -----------------------------LSP AND COMPLETION----------------------------- {{{
  {
    "VonHeikemen/lsp-zero.nvim",
    dependencies = {
      -- LSP Support
      "neovim/nvim-lspconfig",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",

      -- Autocompletion
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lua",
      "onsails/lspkind.nvim",

      -- Snippets
      {
        "L3MON4D3/LuaSnip",
        config = function() require(config_namespace .. ".plugins.luasnip").setup() end,
      },
      "rafamadriz/friendly-snippets",
    },
    config = function() require(config_namespace .. ".plugins.lsp_zero") end,
  },
  {
    "jayp0521/mason-null-ls.nvim", -- Automatically install null-ls servers
    dependencies = {
      "williamboman/mason.nvim",
      "jose-elias-alvarez/null-ls.nvim", -- General purpose LSP server for running linters, formatters, etc
    },
    config = function() require(config_namespace .. ".plugins.null-ls") end,
  },
  ---------------------------------------------------------------------------- }}}
  -----------------------------------SYNTAX----------------------------------- {{{
  {
    "nvim-treesitter/nvim-treesitter", -- Smarter code understanding like syntax Highlight and navigation
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects", -- Syntax aware text-objects, select, move, swap, and peek support.
      "JoosepAlviste/nvim-ts-context-commentstring", -- Smart commenting in multi language files - Enabled in Treesitter file
      "windwp/nvim-ts-autotag", -- Autoclose and autorename HTML and Vue tags
      {
        "windwp/nvim-autopairs", -- Autopair plugin
        config = function() require(config_namespace .. ".plugins.others").nvim_autopairs() end,
      },
      {
        "abecodes/tabout.nvim", -- Tab out from parenthesis, quotes, brackets...
        config = function() require(config_namespace .. ".plugins.others").tabout() end,
      },
    },
    config = function() require(config_namespace .. ".plugins.treesitter") end,
  },
  {
    "nvim-treesitter/playground", -- View Treesitter definitions
    cmd = { "TSPlaygroundToggle", "TSHighlightCapturesUnderCursor" },
  },
  ---------------------------------------------------------------------------- }}}
  ----------------------------TESTING AND DEBUGGING--------------------------- {{{
  {
    "nvim-neotest/neotest",
    dependencies = {
      { dir = "~/Code/Projects/neotest-rspec" },
      { dir = "~/Code/Projects/neotest-phpunit" },
      "nvim-neotest/neotest-plenary",
      "nvim-neotest/neotest-python",
      "antoinemadec/FixCursorHold.nvim",
    },
    config = function() require(config_namespace .. ".plugins.neotest").setup() end,
  },
  {
    "stevearc/overseer.nvim", -- Task runner and job management
    config = function() require(config_namespace .. ".plugins.others").overseer() end,
  },
  {
    "andythigpen/nvim-coverage", -- Display test coverage information
    lazy = true,
    config = function() require(config_namespace .. ".plugins.others").coverage() end,
  },
  {
    "mfussenegger/nvim-dap", -- Debug Adapter Protocol for Neovim
    lazy = true,
    dependencies = {
      "theHamsta/nvim-dap-virtual-text", -- help to find variable definitions in debug mode
      "rcarriga/nvim-dap-ui", -- Nice UI for nvim-dap
    },
    config = function() require(config_namespace .. ".plugins.dap") end,
  },
  ---------------------------------------------------------------------------- }}}
  ------------------------------NEOVIM UTILITIES------------------------------ {{{
  {
    -- "olimorris/persisted.nvim", -- Session management
    dir = "~/Code/Projects/persisted.nvim",
    lazy = true,
    config = function()
      require(config_namespace .. ".plugins.others").persisted()
      require("telescope").load_extension("persisted")
    end,
  },
  {
    "ahmedkhalf/project.nvim", -- Automatically set the cwd to the project root
    config = function()
      require(config_namespace .. ".plugins.others").project_nvim()
      require("telescope").load_extension("projects")
    end,
  },
  {
    "akinsho/nvim-toggleterm.lua", -- Easily toggle and position the terminal
    config = function() require(config_namespace .. ".plugins.others").toggleterm() end,
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
}, opts)
---------------------------------------------------------------------------- }}}
