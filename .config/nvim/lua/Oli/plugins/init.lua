-- The plugins that are imperative to start at boot
local autoload = function()
  return {
    {
      "nathom/filetype.nvim", -- Replace default filetype.vim which is slower
      lock = LockPlugins,
    },
    {
      "tpope/vim-sleuth", -- Automatically detects which indents should be used in the current buffer
      lock = LockPlugins,
    },
    {
      "nvim-lua/plenary.nvim", -- Required dependency for many plugins. Super useful Lua functions
      lock = LockPlugins,
    },
    {
      "antoinemadec/FixCursorHold.nvim", -- Fix neovim CursorHold and CursorHoldI autocmd events performance bug
      lock = LockPlugins,
    },
    {
      "lewis6991/impatient.nvim", -- Speeds up load times
      lock = LockPlugins,
    },
  }
end

local appearance = function()
  return {
    -- use({ "olimorris/onedarkpro.nvim" })
    -- use({
    --     "~/Code/Projects/onedarkpro.nvim",
    --     config = function()
    --         require("onedarkpro").load()
    --     end
    -- }) -- My theme
    {
      "~/Code/Projects/onedarkpro.nvim",
      config = function()
        require(config_namespace .. ".plugins.theme").setup()
      end,
    }, -- My theme
    {
      "goolord/alpha-nvim", -- Dashboard for Neovim
      lock = LockPlugins,
      config = function()
        require(config_namespace .. ".plugins.dashboard").setup()
      end,
    },
    {
      "feline-nvim/feline.nvim", -- Lua statusline
      lock = LockPlugins,
      requires = {
        { "kyazdani42/nvim-web-devicons", lock = LockPlugins }, -- Web icons for various plugins
      },
      config = function()
        require(config_namespace .. ".plugins.statusline").setup()
      end,
    },
    {
      "noib3/cokeline.nvim", -- Buffers in the tabline
      lock = LockPlugins,
      config = function()
        require(config_namespace .. ".plugins.bufferline").setup()
      end,
    },
    {
      "famiu/bufdelete.nvim", -- Easily close buffers whilst preserving your window layouts
      lock = LockPlugins,
      cmd = { "Bdelete", "Bwipeout" },
    },
    {
      "lewis6991/gitsigns.nvim", -- Git signs in the sign column
      lock = LockPlugins,
      event = "BufRead",
      config = function()
        require(config_namespace .. ".plugins.gitsigns")
      end,
    },
    {
      "kyazdani42/nvim-tree.lua", -- File explorer
      lock = LockPlugins,
      requires = "nvim-web-devicons",
      cmd = {
        "NvimTreeToggle",
        "NvimTreeOpen",
        "NvimTreeFindFile",
        "NvimTreeFocus",
      },
      setup = function()
        require(config_namespace .. ".plugins.file_explorer").setup()
      end,
      config = function()
        require(config_namespace .. ".plugins.file_explorer").config()
      end,
    },
    {
      "stevearc/dressing.nvim", -- Utilises Neovim 0.6's new UI hooks to manage inputs, selects etc
      lock = LockPlugins,
      config = function()
        require(config_namespace .. ".plugins.others").dressing()
      end,
    },
    {
      "norcalli/nvim-colorizer.lua", -- Highlight hex and rgb colors within Neovim
      lock = LockPlugins,
      cmd = { "Colorizer*" },
      config = function()
        require(config_namespace .. ".plugins.others").colorizer()
      end,
    },
    {
      "lukas-reineke/headlines.nvim", -- Highlight headlines and code blocks in Markdown
      lock = LockPlugins,
      ft = "markdown",
      config = function()
        local ok, headlines = om.safe_require("headlines")
        if ok then
          headlines.setup()
        end
      end,
    },
    {
      "wfxr/minimap.vim", -- Display a minimap
      lock = LockPlugins,
      cmd = { "MinimapToggle", "Minimap", "MinimapRefresh" },
      config = function()
        require(config_namespace .. ".plugins.others").minimap()
      end,
    },
    {
      "lukas-reineke/indent-blankline.nvim", -- Show indentation lines
      lock = LockPlugins,
      event = "BufRead",
      config = function()
        require(config_namespace .. ".plugins.others").indentline()
      end,
    },
    {
      "stevearc/qf_helper.nvim", -- Improves the quickfix and location list windows
      lock = LockPlugins,
      cmd = { "copen", "lopen", "QFToggle", "LLToggle", "QFOpen", "LLOpen" },
      config = function()
        require(config_namespace .. ".plugins.others").qf_helper()
      end,
    },
  }
end

local editor_features = function()
  return {
    {
      -- "olimorris/persisted.nvim", -- Session management
      "~/Code/Projects/persisted.nvim",
      module = "persisted",
      config = function()
        require(config_namespace .. ".plugins.others").persisted()
      end,
    },

    {
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
    },
    {
      "beauwilliams/focus.nvim", -- Auto-resize splits/windows
      lock = LockPlugins,
      module = "focus",
      config = function()
        require(config_namespace .. ".plugins.others").focus()
      end,
    },
    {
      "mbbill/undotree", -- Visually see your undos
      lock = LockPlugins,
      cmd = "UndotreeToggle",
      config = function()
        require(config_namespace .. ".plugins.others").undotree()
      end,
    },
    {
      "VonHeikemen/searchbox.nvim", -- Search box in the top right corner
      lock = LockPlugins,
      module = "searchbox",
      requires = {
        { "MunifTanjim/nui.nvim", lock = LockPlugins },
      },
      config = function()
        require(config_namespace .. ".plugins.others").search()
      end,
    },
    {
      "phaazon/hop.nvim", -- Speedily navigate anywhere in a buffer
      lock = LockPlugins,
      module = "hop",
      config = function()
        require(config_namespace .. ".plugins.others").hop()
      end,
    },
    {
      "AckslD/nvim-neoclip.lua", -- Clipboard history
      lock = LockPlugins,
      requires = {
        { "tami5/sqlite.lua", lock = LockPlugins },
      },
      config = function()
        require(config_namespace .. ".plugins.others").neoclip()
      end,
    },
    {
      "akinsho/nvim-toggleterm.lua", -- Easily toggle and position the terminal
      lock = LockPlugins,
      cmd = { "ToggleTerm", "Test*" },
      config = function()
        require(config_namespace .. ".plugins.others").toggleterm()
      end,
    },
    {
      "mrjones2014/legendary.nvim",
      config = function()
        require(config_namespace .. ".plugins.legendary").setup()
      end,
    },
  }
end

local completion = function()
  return {
    {
      "hrsh7th/nvim-cmp", -- Code completion menu
      lock = LockPlugins,
      requires = {
        {
          "L3MON4D3/LuaSnip", -- Code snippets
          lock = LockPlugins,
          event = "InsertEnter",
          module = "luasnip",
          requires = {
            {
              "rafamadriz/friendly-snippets", -- Collection of code snippets across many languages
              lock = LockPlugins,
            },
          },
          config = function()
            require(config_namespace .. ".plugins.others").luasnip()
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
        require(config_namespace .. ".plugins.cmp")
      end,
    },
    {
      "windwp/nvim-autopairs", -- Automatically inserts a closing bracket, moustache etc
      lock = LockPlugins,
      after = "nvim-cmp",
      config = function()
        require(config_namespace .. ".plugins.others").autopairs()
      end,
    },
  }
end

local coding = function()
  return {
    {
      "williamboman/nvim-lsp-installer", -- Install LSP servers from within Neovim
      lock = LockPlugins,
      requires = {
        { "neovim/nvim-lspconfig", lock = LockPlugins }, -- Use Neovims native LSP config
        { "kosayoda/nvim-lightbulb", lock = LockPlugins }, -- VSCode style lightbulb if there is a code action available
      },
      config = function()
        require(config_namespace .. ".plugins.lsp")
      end,
    },
    {
      "jose-elias-alvarez/null-ls.nvim", -- General language server to enable awesome things with the LSP
      lock = LockPlugins,
      event = "BufRead",
      config = function()
        require(config_namespace .. ".plugins.null-ls")
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter", -- Syntax highlighting and code navigation for Neovim
      lock = LockPlugins,
      event = { "BufRead", "BufNewFile" },
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
      },
      config = function()
        require(config_namespace .. ".plugins.treesitter")
      end,
    },
    {
      "nvim-treesitter/playground", -- View Treesitter definitions
      lock = LockPlugins,
      cmd = { "TSPlaygroundToggle", "TSHighlightCapturesUnderCursor" },
    },
    {
      "pianocomposer321/yabs.nvim", -- Build and run your code
      lock = LockPlugins,
      module = "yabs",
      config = function()
        require(config_namespace .. ".plugins.others").yabs()
      end,
    },
    {
      "abecodes/tabout.nvim", -- Tab out from parenthesis, quotes, brackets...
      lock = LockPlugins,
      after = "nvim-cmp",
      config = function()
        require(config_namespace .. ".plugins.others").tabout()
      end,
    },
    {
      "tpope/vim-surround", -- Use vim commands to surround text, tags with brackets, parenthesis etc
      lock = LockPlugins,
      event = "InsertEnter",
    },
    {
      "folke/todo-comments.nvim", -- Highlight and search for todo comments within the codebase
      lock = LockPlugins,
      event = "BufRead",
      config = function()
        require(config_namespace .. ".plugins.others").todo_comments()
      end,
    },
    {
      "numToStr/Comment.nvim", -- Comment out lines with gcc
      lock = LockPlugins,
      module = "Comment",
      keys = { "gcc", "gc", "gbc" },
      config = function()
        require(config_namespace .. ".plugins.others").comment()
      end,
    },
    {
      "vim-test/vim-test", -- Run tests on any type of code base
      lock = LockPlugins,
      cmd = { "Test*" },
      setup = function()
        require(config_namespace .. ".plugins.testing").vim_test()
      end,
    },
    {
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
    },
    {
      "ahmedkhalf/project.nvim", -- Automatically set the cwd to the project root
      lock = LockPlugins,
      event = "BufRead",
      config = function()
        require(config_namespace .. ".plugins.others").project_nvim()
      end,
    },
    {
      "github/copilot.vim", -- AI programming
      lock = LockPlugins,
      cmd = "Copilot",
    },
  }
end

local others = function()
  return {
    {
      "nathom/tmux.nvim", -- Navigate Tmux panes inside of neovim
      lock = LockPlugins,
      cond = function()
        return os.getenv("TMUX")
      end,
    },
    {
      "dstein64/vim-startuptime", -- Profile your Neovim startup time
      lock = LockPlugins,
      cmd = "StartupTime",
      config = function()
        vim.g.startuptime_tries = 15
        vim.g.startuptime_exe_args = { "+let g:auto_session_enabled = 0" }
      end,
    },
  }
end

return {
  autoload(),
  appearance(),
  editor_features(),
  completion(),
  coding(),
  others(),
}
