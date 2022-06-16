local M = {}

M.plugins = {
  ----------------------------------AUTOLOAD---------------------------------- {{{
  {
    "wbthomason/packer.nvim",
    opt = "true",
  },
  {
    "nathom/filetype.nvim", -- Replace default filetype.vim which is slower
  },
  {
    "tpope/vim-sleuth", -- Automatically detects which indents should be used in the current buffer
  },
  {
    "nvim-lua/plenary.nvim", -- Required dependency for many plugins. Super useful Lua functions
  },
  {
    "antoinemadec/FixCursorHold.nvim", -- Fix neovim CursorHold and CursorHoldI autocmd events performance bug
  },
  {
    "lewis6991/impatient.nvim", -- Speeds up load times
  },
  ---------------------------------------------------------------------------- }}}
  ---------------------------------APPEARANCE--------------------------------- {{{
  {
    --"olimorris/onedarkpro.nvim",
    "~/Code/Projects/onedarkpro.nvim", -- My onedarkpro theme
    config = function()
      require(config_namespace .. ".plugins.theme").setup()
    end,
  },
  {
    "goolord/alpha-nvim", -- Dashboard for Neovim
    config = function()
      require(config_namespace .. ".plugins.dashboard").setup()
    end,
  },
  {
    "feline-nvim/feline.nvim", -- Statusline
    requires = {
      { "kyazdani42/nvim-web-devicons" }, -- Web icons for various plugins
    },
    config = function()
      require(config_namespace .. ".plugins.statusline").setup()
    end,
  },
  {
    "noib3/cokeline.nvim", -- Bufferline
    config = function()
      require(config_namespace .. ".plugins.bufferline").setup()
    end,
  },
  {
    "famiu/bufdelete.nvim", -- Easily close buffers whilst preserving your window layouts
    cmd = { "Bdelete", "Bwipeout" },
  },
  {
    "lewis6991/gitsigns.nvim", -- Git signs in the sign column
    config = function()
      require(config_namespace .. ".plugins.gitsigns")
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    requires = {
      { "nvim-lua/plenary.nvim" },
      { "kyazdani42/nvim-web-devicons" },
      { "MunifTanjim/nui.nvim" },
    },
    config = function()
      require(config_namespace .. ".plugins.file_explorer").config()
    end,
  },
  {
    "stevearc/dressing.nvim", -- Utilises Neovim 0.6's new UI hooks to manage inputs, selects etc
    config = function()
      require(config_namespace .. ".plugins.others").dressing()
    end,
  },
  {
    "norcalli/nvim-colorizer.lua", -- Highlight hex and rgb colors within Neovim
    cmd = { "Colorizer*" },
    config = function()
      require(config_namespace .. ".plugins.others").colorizer()
    end,
  },
  {
    "lukas-reineke/headlines.nvim", -- Highlight headlines and code blocks in Markdown
    ft = "markdown",
    config = function()
      require(config_namespace .. ".plugins.others").headlines()
    end,
  },
  {
    "wfxr/minimap.vim", -- Display a minimap
    cmd = { "MinimapToggle", "Minimap", "MinimapRefresh" },
    config = function()
      require(config_namespace .. ".plugins.others").minimap()
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim", -- Show indentation lines
    config = function()
      require(config_namespace .. ".plugins.others").indentline()
    end,
  },
  {
    "stevearc/qf_helper.nvim", -- Improves the quickfix and location list windows
    cmd = { "copen", "lopen", "QFToggle", "LLToggle", "QFOpen", "LLOpen" },
    config = function()
      require(config_namespace .. ".plugins.others").qf_helper()
    end,
  },
  ---------------------------------------------------------------------------- }}}
  -------------------------------EDITOR FEATURES------------------------------ {{{
  {
    -- "olimorris/persisted.nvim", -- Session management
    "~/Code/Projects/persisted.nvim",
    module = "persisted",
    config = function()
      require(config_namespace .. ".plugins.others").persisted()
      require("telescope").load_extension("persisted")
    end,
  },
  {
    "nvim-telescope/telescope.nvim", -- Awesome fuzzy finder for everything
    requires = {
      {
        "nvim-telescope/telescope-project.nvim", -- Switch between projects
        after = "telescope.nvim",
        config = function()
          require("telescope").load_extension("project")
        end,
      },
      {
        "nvim-telescope/telescope-fzf-native.nvim", -- Use fzf within Telescope
        run = "make",
        after = "telescope.nvim",
        config = function()
          require("telescope").load_extension("fzf")
        end,
      },
      {
        "nvim-telescope/telescope-frecency.nvim", -- Get frequently opened files
        after = "telescope.nvim",
        requires = {
          { "tami5/sqlite.lua" },
        },
        config = function()
          require("telescope").load_extension("frecency")
        end,
      },
      {
        "nvim-telescope/telescope-smart-history.nvim", -- Show project dependant history
        after = "telescope.nvim",
        requires = {
          { "tami5/sqlite.lua" },
        },
        config = function()
          require("telescope").load_extension("smart_history")
        end,
      },
      {
        "ThePrimeagen/harpoon", -- Mark buffers for faster navigation
        module = "harpoon",
        after = "telescope.nvim",
        config = function()
          require("telescope").load_extension("harpoon")
          require(config_namespace .. ".plugins.others").harpoon()
        end,
      },
      {
        "stevearc/aerial.nvim", -- Toggled list of classes, methods etc in current file
        cmd = "AerialToggle",
        module = "aerial",
        after = "telescope.nvim",
        config = function()
          require("telescope").load_extension("aerial")
          require(config_namespace .. ".plugins.others").aerial()
        end,
      },
    },
    config = function()
      require(config_namespace .. ".plugins.telescope")
    end,
  },
  {
    "mbbill/undotree", -- Visually see your undos
    cmd = "UndotreeToggle",
    config = function()
      require(config_namespace .. ".plugins.others").undotree()
    end,
  },
  {
    "VonHeikemen/searchbox.nvim", -- Search box in the top right corner
    cmd = "SearchBox*",
    module = "searchbox",
    requires = {
      { "MunifTanjim/nui.nvim" },
    },
    config = function()
      require(config_namespace .. ".plugins.others").search()
    end,
  },
  {
    "phaazon/hop.nvim", -- Speedily navigate anywhere in a buffer
    module = "hop",
    config = function()
      require(config_namespace .. ".plugins.others").hop()
    end,
  },
  {
    "akinsho/nvim-toggleterm.lua", -- Easily toggle and position the terminal
    cmd = { "ToggleTerm", "Test*" },
    config = function()
      require(config_namespace .. ".plugins.others").toggleterm()
    end,
  },
  {
    "mrjones2014/legendary.nvim", -- A legend for all keymaps, commands and autocmds
    config = function()
      require(config_namespace .. ".plugins.legendary").setup()
    end,
  },
  ---------------------------------------------------------------------------- }}}
  ---------------------------------COMPLETION--------------------------------- {{{
  {
    "hrsh7th/nvim-cmp", -- Code completion menu
    requires = {
      {
        "L3MON4D3/LuaSnip", -- Code snippets
        requires = {
          {
            "rafamadriz/friendly-snippets", -- Collection of code snippets across many languages
          },
          {
            "danymat/neogen", -- Generate annotations for functions
            config = function()
              require(config_namespace .. ".plugins.others").neogen()
            end,
          },
        },
        config = function()
          require(config_namespace .. ".plugins.luasnip").setup()
          require(config_namespace .. ".plugins.luasnip").snippets()
        end,
      },
      -- cmp sources --
      { "saadparwaiz1/cmp_luasnip" },
      { "hrsh7th/cmp-nvim-lua" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
    },
    config = function()
      require(config_namespace .. ".plugins.completion")
    end,
  },
  ---------------------------------------------------------------------------- }}}
  -----------------------------------CODING----------------------------------- {{{
  {
    "~/Code/Projects/refactoring.nvim",
    requires = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-treesitter/nvim-treesitter" },
    },
    config = function()
      require(config_namespace .. ".plugins.others").refactoring()
      require("telescope").load_extension("refactoring")
    end,
  },
  {
    "williamboman/nvim-lsp-installer", -- Install LSP servers from within Neovim
    requires = {
      { "neovim/nvim-lspconfig" }, -- Use Neovims native LSP config
      { "kosayoda/nvim-lightbulb" }, -- VSCode style lightbulb if there is a code action available
      {
        "j-hui/fidget.nvim", -- LSP progress notifications
        config = function()
          require(config_namespace .. ".plugins.others").fidget()
        end,
      },
    },
    config = function()
      require(config_namespace .. ".plugins.lsp")
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim", -- General language server for linting, formatting etc
    after = "nvim-lsp-installer",
    config = function()
      require(config_namespace .. ".plugins.null-ls")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter", -- Smarter code understanding like syntax Highlight and navigation
    run = ":TSUpdate",
    requires = {
      {
        "windwp/nvim-ts-autotag", -- Autoclose and autorename HTML and Vue tags
        after = "nvim-treesitter",
      },
      {
        "windwp/nvim-autopairs", -- Autopair plugin
        after = "nvim-treesitter",
        config = function()
          require(config_namespace .. ".plugins.others").nvim_autopairs()
        end,
      },
      {
        "JoosepAlviste/nvim-ts-context-commentstring", -- Smart commenting in multi language files - Enabled in Treesitter file
        after = "nvim-treesitter",
      },
      {
        "David-Kunz/treesitter-unit", -- Better selection of Treesitter code
        after = "nvim-treesitter",
      },
      {
        "RRethy/nvim-treesitter-endwise", -- add "end" in Ruby and other languages
        after = "nvim-treesitter",
      },
      {
        "nvim-treesitter/nvim-treesitter-textobjects", -- Syntax aware text-objects, select, move, swap, and peek support.
        after = "nvim-treesitter",
      },
      {
        "m-demare/hlargs.nvim", --Highlight argument definitions
        config = function()
          require(config_namespace .. ".plugins.others").hlargs()
        end,
      },
    },
    config = function()
      require(config_namespace .. ".plugins.treesitter")
    end,
  },
  {
    "nvim-treesitter/playground", -- View Treesitter definitions
    cmd = { "TSPlaygroundToggle", "TSHighlightCapturesUnderCursor" },
  },
  {
    "abecodes/tabout.nvim", -- Tab out from parenthesis, quotes, brackets...
    after = "nvim-cmp",
    wants = "nvim-treesitter",
    config = function()
      require(config_namespace .. ".plugins.others").tabout()
    end,
  },
  {
    "tpope/vim-surround", -- Use vim commands to surround text, tags with brackets, parenthesis etc
  },
  {
    "folke/todo-comments.nvim", -- Highlight and search for todo comments within the codebase
    event = "BufRead",
    config = function()
      require(config_namespace .. ".plugins.others").todo_comments()
    end,
  },
  {
    "numToStr/Comment.nvim", -- Comment out lines with gcc
    module = "Comment",
    keys = { "gcc", "gc", "gbc" },
    config = function()
      require(config_namespace .. ".plugins.others").comment()
    end,
  },
  {
    "fedepujol/move.nvim", -- Move lines and blocks
    cmd = { "MoveLine", "MoveBlock", "MoveHChar", "MoveHBlock" },
  },
  {
    "pianocomposer321/yabs.nvim", -- Build and run your code
    module = "yabs",
    config = function()
      require(config_namespace .. ".plugins.others").yabs()
    end,
  },
  {
    "vim-test/vim-test", -- Run tests on any type of code base
    cmd = { "Test*" },
    setup = function()
      require(config_namespace .. ".plugins.testing").vim_test()
    end,
  },
  {
    "nvim-neotest/neotest",
    requires = {
      "~/Code/Projects/neotest-rspec",
      "haydenmeade/neotest-jest",
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-go",
      "antoinemadec/FixCursorHold.nvim",
    },
    config = function()
      require(config_namespace .. ".plugins.testing").neotest()
    end,
  },
  {
    "andythigpen/nvim-coverage", -- Display test coverage information
    module = "coverage",
    config = function()
      require(config_namespace .. ".plugins.testing").coverage()
    end,
  },
  {
    "mfussenegger/nvim-dap", -- Debug Adapter Protocol for Neovim
    module = "dap",
    requires = {
      {
        "suketa/nvim-dap-ruby", -- Ruby rdbg config
        after = "nvim-dap",
        config = function()
          require("dap-ruby").setup()
        end,
      },
      {
        "theHamsta/nvim-dap-virtual-text", -- help to find variable definitions in debug mode
        after = "nvim-dap",
        config = function()
          require("nvim-dap-virtual-text").setup()
        end,
      },
      {
        "rcarriga/nvim-dap-ui", -- Nice UI for debugging
        after = "nvim-dap",
        config = function()
          require(config_namespace .. ".plugins.others").dap_ui()
        end,
      },
    },
    config = function()
      require(config_namespace .. ".plugins.others").dap()
    end,
  },
  {
    "ahmedkhalf/project.nvim", -- Automatically set the cwd to the project root
    config = function()
      require(config_namespace .. ".plugins.others").project_nvim()
    end,
  },
  {
    "github/copilot.vim", -- AI programming
    cmd = "Copilot",
  },
  ---------------------------------------------------------------------------- }}}
  -----------------------------------OTHERS----------------------------------- {{{
  {
    "stevearc/stickybuf.nvim", -- Ensure buffers are not opened in certain filetypes
    config = function()
      require(config_namespace .. ".plugins.others").stickybuf()
    end,
  },
  {
    "nathom/tmux.nvim", -- Navigate Tmux panes inside of neovim
    cond = function()
      return os.getenv("TMUX")
    end,
  },
  {
    "dstein64/vim-startuptime", -- Profile your Neovim startup time
    cmd = "StartupTime",
    config = function()
      vim.g.startuptime_tries = 15
      vim.g.startuptime_exe_args = { "+let g:auto_session_enabled = 0" }
    end,
  },
  ---------------------------------------------------------------------------- }}}
}

M.lua_rocks = {
  "penlight"
}

return M
