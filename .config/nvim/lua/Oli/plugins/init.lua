----------------------------------BOOTSTRAP--------------------------------- {{{
local PACKER_COMPILED_PATH = vim.fn.stdpath("cache") .. "/packer/packer_compiled.lua"
local PACKER_INSTALLED_PATH = vim.fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"

-- Install Packer if it doesn't exist
local packer_install = false

if vim.fn.empty(vim.fn.glob(PACKER_INSTALLED_PATH)) > 0 then
  vim.notify("Downloading packer.nvim...", nil, { title = "Packer" })
  packer_install = vim.fn.system({
    "git",
    "clone",
    "https://github.com/wbthomason/packer.nvim",
    PACKER_INSTALLED_PATH,
  })
  vim.cmd("packadd packer.nvim")
end

local packer = require("packer")
---------------------------------------------------------------------------- }}}
-----------------------------------PLUGINS---------------------------------- {{{
return packer.startup({
  function(use, use_rocks)
    ----------------------------------AUTOLOAD---------------------------------- {{{
    -- use_rocks("penlight")
    use({
      "wbthomason/packer.nvim",
      opt = "true",
    })
    use({
      "nathom/filetype.nvim", -- Replace default filetype.vim which is slower
      lock = LockPlugins,
    })
    use({
      "tpope/vim-sleuth", -- Automatically detects which indents should be used in the current buffer
      lock = LockPlugins,
    })
    use({
      "nvim-lua/plenary.nvim", -- Required dependency for many plugins. Super useful Lua functions
      lock = LockPlugins,
    })
    use({
      "antoinemadec/FixCursorHold.nvim", -- Fix neovim CursorHold and CursorHoldI autocmd events performance bug
      lock = LockPlugins,
    })
    use({
      "lewis6991/impatient.nvim", -- Speeds up load times
      lock = LockPlugins,
    })
    ---------------------------------------------------------------------------- }}}
    ---------------------------------APPEARANCE--------------------------------- {{{
    use({
      --"olimorris/onedarkpro.nvim",
      "~/Code/Projects/onedarkpro.nvim", -- My onedarkpro theme
      config = function()
        require(config_namespace .. ".plugins.theme").setup()
      end,
    })
    use({
      "goolord/alpha-nvim", -- Dashboard for Neovim
      lock = LockPlugins,
      config = function()
        require(config_namespace .. ".plugins.dashboard").setup()
      end,
    })
    use({
      "feline-nvim/feline.nvim", -- Statusline
      lock = LockPlugins,
      requires = {
        { "kyazdani42/nvim-web-devicons", lock = LockPlugins }, -- Web icons for various plugins
      },
      config = function()
        require(config_namespace .. ".plugins.statusline").setup()
      end,
    })
    use({
      "noib3/cokeline.nvim", -- Bufferline
      lock = LockPlugins,
      config = function()
        require(config_namespace .. ".plugins.bufferline").setup()
      end,
    })
    use({
      "famiu/bufdelete.nvim", -- Easily close buffers whilst preserving your window layouts
      lock = LockPlugins,
      cmd = { "Bdelete", "Bwipeout" },
    })
    use({
      "lewis6991/gitsigns.nvim", -- Git signs in the sign column
      lock = LockPlugins,
      config = function()
        require(config_namespace .. ".plugins.gitsigns")
      end,
    })
    use({
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v2.x",
      lock = LockPlugins,
      requires = {
        { "nvim-lua/plenary.nvim", lock = LockPlugins },
        { "kyazdani42/nvim-web-devicons", lock = LockPlugins },
        { "MunifTanjim/nui.nvim", lock = LockPlugins },
      },
      config = function()
        require(config_namespace .. ".plugins.file_explorer").config()
      end,
    })
    use({
      "stevearc/dressing.nvim", -- Utilises Neovim 0.6's new UI hooks to manage inputs, selects etc
      lock = LockPlugins,
      config = function()
        require(config_namespace .. ".plugins.others").dressing()
      end,
    })
    use({
      "norcalli/nvim-colorizer.lua", -- Highlight hex and rgb colors within Neovim
      lock = LockPlugins,
      cmd = { "Colorizer*" },
      config = function()
        require(config_namespace .. ".plugins.others").colorizer()
      end,
    })
    use({
      "lukas-reineke/headlines.nvim", -- Highlight headlines and code blocks in Markdown
      lock = LockPlugins,
      ft = "markdown",
      config = function()
        require(config_namespace .. ".plugins.others").headlines()
      end,
    })
    use({
      "wfxr/minimap.vim", -- Display a minimap
      lock = LockPlugins,
      cmd = { "MinimapToggle", "Minimap", "MinimapRefresh" },
      config = function()
        require(config_namespace .. ".plugins.others").minimap()
      end,
    })
    use({
      "lukas-reineke/indent-blankline.nvim", -- Show indentation lines
      lock = LockPlugins,
      config = function()
        require(config_namespace .. ".plugins.others").indentline()
      end,
    })
    use({
      "stevearc/qf_helper.nvim", -- Improves the quickfix and location list windows
      lock = LockPlugins,
      cmd = { "copen", "lopen", "QFToggle", "LLToggle", "QFOpen", "LLOpen" },
      config = function()
        require(config_namespace .. ".plugins.others").qf_helper()
      end,
    })
    ---------------------------------------------------------------------------- }}}
    -------------------------------EDITOR FEATURES------------------------------ {{{
    use({
      -- "olimorris/persisted.nvim", -- Session management
      "~/Code/Projects/persisted.nvim",
      -- module = "persisted",
      config = function()
        require(config_namespace .. ".plugins.others").persisted()
        require("telescope").load_extension("persisted")
      end,
    })
    use({
      "nvim-telescope/telescope.nvim", -- Awesome fuzzy finder for everything
      lock = LockPlugins,
      cmd = "Telescope",
      module_pattern = "telescope.*",
      requires = {
        {
          "nvim-telescope/telescope-project.nvim", -- Switch between projects
          lock = LockPlugins,
          after = "telescope.nvim",
          config = function()
            require("telescope").load_extension("project")
          end,
        },
        {
          "nvim-telescope/telescope-fzf-native.nvim", -- Use fzf within Telescope
          lock = LockPlugins,
          run = "make",
          after = "telescope.nvim",
          config = function()
            require("telescope").load_extension("fzf")
          end,
        },
        {
          "nvim-telescope/telescope-frecency.nvim", -- Get frequently opened files
          lock = LockPlugins,
          after = "telescope.nvim",
          requires = {
            { "tami5/sqlite.lua", lock = LockPlugins },
          },
          config = function()
            require("telescope").load_extension("frecency")
          end,
        },
        {
          "nvim-telescope/telescope-smart-history.nvim", -- Show project dependant history
          lock = LockPlugins,
          after = "telescope.nvim",
          requires = {
            { "tami5/sqlite.lua", lock = LockPlugins },
          },
          config = function()
            require("telescope").load_extension("smart_history")
          end,
        },
        {
          "ThePrimeagen/harpoon", -- Mark buffers for faster navigation
          lock = LockPlugins,
          module = "harpoon",
          after = "telescope.nvim",
          config = function()
            require("telescope").load_extension("harpoon")
            require(config_namespace .. ".plugins.others").harpoon()
          end,
        },
        {
          "stevearc/aerial.nvim", -- Toggled list of classes, methods etc in current file
          lock = LockPlugins,
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
    })
    use({
      "beauwilliams/focus.nvim", -- Auto-resize splits/windows
      lock = LockPlugins,
      module = "focus",
      config = function()
        require(config_namespace .. ".plugins.others").focus()
      end,
    })
    use({
      "mbbill/undotree", -- Visually see your undos
      lock = LockPlugins,
      cmd = "UndotreeToggle",
      config = function()
        require(config_namespace .. ".plugins.others").undotree()
      end,
    })
    use({
      "VonHeikemen/searchbox.nvim", -- Search box in the top right corner
      lock = LockPlugins,
      cmd = "SearchBox*",
      module = "searchbox",
      requires = {
        { "MunifTanjim/nui.nvim", lock = LockPlugins },
      },
      config = function()
        require(config_namespace .. ".plugins.others").search()
      end,
    })
    use({
      "phaazon/hop.nvim", -- Speedily navigate anywhere in a buffer
      lock = LockPlugins,
      module = "hop",
      config = function()
        require(config_namespace .. ".plugins.others").hop()
      end,
    })
    use({
      "akinsho/nvim-toggleterm.lua", -- Easily toggle and position the terminal
      lock = LockPlugins,
      cmd = { "ToggleTerm", "Test*" },
      config = function()
        require(config_namespace .. ".plugins.others").toggleterm()
      end,
    })
    use({
      "mrjones2014/legendary.nvim", -- A legend for all keymaps, commands and autocmds
      lock = LockPlugins,
      config = function()
        -- Do not reload this plugin
        if vim.g.packer_reloaded then
          return
        end
        require(config_namespace .. ".plugins.legendary").setup()
      end,
    })
    ---------------------------------------------------------------------------- }}}
    ---------------------------------COMPLETION--------------------------------- {{{
    use({
      "hrsh7th/nvim-cmp", -- Code completion menu
      lock = LockPlugins,
      requires = {
        {
          "L3MON4D3/LuaSnip", -- Code snippets
          lock = LockPlugins,
          requires = {
            {
              "rafamadriz/friendly-snippets", -- Collection of code snippets across many languages
              lock = LockPlugins,
            },
            {
              "danymat/neogen", -- Generate annotations for functions
              lock = LockPlugins,
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
        { "onsails/lspkind-nvim", lock = LockPlugins }, -- VS Code like icons
        -- cmp sources --
        { "saadparwaiz1/cmp_luasnip", lock = LockPlugins },
        { "hrsh7th/cmp-nvim-lua", lock = LockPlugins },
        { "hrsh7th/cmp-nvim-lsp", lock = LockPlugins },
        { "hrsh7th/cmp-buffer", lock = LockPlugins },
        { "hrsh7th/cmp-path", lock = LockPlugins },
      },
      config = function()
        require(config_namespace .. ".plugins.completion")
      end,
    })
    ---------------------------------------------------------------------------- }}}
    -----------------------------------CODING----------------------------------- {{{
    use({
      "williamboman/nvim-lsp-installer", -- Install LSP servers from within Neovim
      lock = LockPlugins,
      requires = {
        { "neovim/nvim-lspconfig", lock = LockPlugins }, -- Use Neovims native LSP config
        { "kosayoda/nvim-lightbulb", lock = LockPlugins }, -- VSCode style lightbulb if there is a code action available
        {
          "j-hui/fidget.nvim", -- LSP progress notifications
          lock = LockPlugins,
          config = function()
            require(config_namespace .. ".plugins.others").fidget()
          end,
        },
      },
      config = function()
        require(config_namespace .. ".plugins.lsp")
      end,
    })
    use({
      "jose-elias-alvarez/null-ls.nvim", -- General language server for linting, formatting etc
      lock = LockPlugins,
      after = "nvim-lsp-installer",
      config = function()
        require(config_namespace .. ".plugins.null-ls")
      end,
    })
    use({
      "nvim-treesitter/nvim-treesitter", -- Smarter code understanding like syntax Highlight and navigation
      lock = LockPlugins,
      run = ":TSUpdate",
      requires = {
        {
          "windwp/nvim-ts-autotag", -- Autoclose and autorename HTML and Vue tags
          lock = LockPlugins,
          after = "nvim-treesitter",
        },
        {
          "JoosepAlviste/nvim-ts-context-commentstring", -- Smart commenting in multi language files - Enabled in Treesitter file
          lock = LockPlugins,
          after = "nvim-treesitter",
        },
        {
          "David-Kunz/treesitter-unit", -- Better selection of Treesitter code
          lock = LockPlugins,
          after = "nvim-treesitter",
        },
        {
          "RRethy/nvim-treesitter-endwise", -- add "end" in Ruby and other languages
          lock = LockPlugins,
          after = "nvim-treesitter",
        },
        {
          "nvim-treesitter/nvim-treesitter-textobjects", -- Syntax aware text-objects, select, move, swap, and peek support.
          lock = LockPlugins,
          after = "nvim-treesitter",
        },
        {
          "SmiteshP/nvim-gps", -- Show the current treesitter location in the statusline
          lock = LockPlugins,
          module = "nvim-gps",
          config = function()
            require(config_namespace .. ".plugins.others").gps()
          end,
        },
        {
          "m-demare/hlargs.nvim", --Highlight argument definitions
          lock = LockPlugins,
          config = function()
            require(config_namespace .. ".plugins.others").hlargs()
          end,
        },
      },
      config = function()
        require(config_namespace .. ".plugins.treesitter")
      end,
    })
    use({
      "nvim-treesitter/playground", -- View Treesitter definitions
      lock = LockPlugins,
      cmd = { "TSPlaygroundToggle", "TSHighlightCapturesUnderCursor" },
    })
    use({
      "abecodes/tabout.nvim", -- Tab out from parenthesis, quotes, brackets...
      lock = LockPlugins,
      after = "nvim-cmp",
      wants = "nvim-treesitter",
      config = function()
        require(config_namespace .. ".plugins.others").tabout()
      end,
    })
    use({
      "tpope/vim-surround", -- Use vim commands to surround text, tags with brackets, parenthesis etc
      lock = LockPlugins,
    })
    use({
      "folke/todo-comments.nvim", -- Highlight and search for todo comments within the codebase
      lock = LockPlugins,
      event = "BufRead",
      config = function()
        require(config_namespace .. ".plugins.others").todo_comments()
      end,
    })
    use({
      "numToStr/Comment.nvim", -- Comment out lines with gcc
      lock = LockPlugins,
      module = "Comment",
      keys = { "gcc", "gc", "gbc" },
      config = function()
        require(config_namespace .. ".plugins.others").comment()
      end,
    })
    use({
      "fedepujol/move.nvim", -- Move lines and blocks
      lock = LockPlugins,
      cmd = { "MoveLine", "MoveBlock", "MoveHChar", "MoveHBlock" },
    })
    use({
      "pianocomposer321/yabs.nvim", -- Build and run your code
      lock = LockPlugins,
      module = "yabs",
      config = function()
        require(config_namespace .. ".plugins.others").yabs()
      end,
    })
    use({
      "vim-test/vim-test", -- Run tests on any type of code base
      lock = LockPlugins,
      cmd = { "Test*" },
      setup = function()
        require(config_namespace .. ".plugins.testing").vim_test()
      end,
    })
    use({
      "andythigpen/nvim-coverage", -- Display test coverage information
      lock = LockPlugins,
      module = "coverage",
      config = function()
        require(config_namespace .. ".plugins.testing").coverage()
      end,
    })
    use({
      "mfussenegger/nvim-dap", -- Debug Adapter Protocol for Neovim
      lock = LockPlugins,
      module = "dap",
      requires = {
        {
          "suketa/nvim-dap-ruby", -- Ruby rdbg config
          lock = LockPlugins,
          after = "nvim-dap",
          config = function()
            require("dap-ruby").setup()
          end,
        },
        {
          "theHamsta/nvim-dap-virtual-text", -- help to find variable definitions in debug mode
          lock = LockPlugins,
          after = "nvim-dap",
          config = function()
            require("nvim-dap-virtual-text").setup()
          end,
        },
        {
          "rcarriga/nvim-dap-ui", -- Nice UI for debugging
          lock = LockPlugins,
          after = "nvim-dap",
          config = function()
            require(config_namespace .. ".plugins.others").dap_ui()
          end,
        },
      },
      config = function()
        require(config_namespace .. ".plugins.others").dap()
      end,
    })
    use({
      "ahmedkhalf/project.nvim", -- Automatically set the cwd to the project root
      lock = LockPlugins,
      config = function()
        require(config_namespace .. ".plugins.others").project_nvim()
      end,
    })
    use({
      "github/copilot.vim", -- AI programming
      lock = LockPlugins,
      cmd = "Copilot",
    })
    ---------------------------------------------------------------------------- }}}
    -----------------------------------OTHERS----------------------------------- {{{
    use({
      "nathom/tmux.nvim", -- Navigate Tmux panes inside of neovim
      lock = LockPlugins,
      cond = function()
        return os.getenv("TMUX")
      end,
    })
    use({
      "dstein64/vim-startuptime", -- Profile your Neovim startup time
      lock = LockPlugins,
      cmd = "StartupTime",
      config = function()
        vim.g.startuptime_tries = 15
        vim.g.startuptime_exe_args = { "+let g:auto_session_enabled = 0" }
      end,
    })
    ---------------------------------------------------------------------------- }}}
    --------------------------------PACKER CONFIG------------------------------- {{{
    if packer_install then
      packer.sync()
    end
  end,
  log = { level = "info" },
  config = {
    display = {
      open_fn = function()
        return require("packer.util").float({ border = "single" })
      end,
    },
    git = {
      clone_timeout = 240, -- Timeout for git clones (seconds)
    },
    auto_clean = true,
    compile_on_sync = true,
    max_jobs = 10,
    profile = {
      enable = true,
      threshold = 1, -- the amount in ms that a plugins load time must be over for it to be included in the profile
    },
  },
})
---------------------------------------------------------------------------- }}}
---------------------------------------------------------------------------- }}}
