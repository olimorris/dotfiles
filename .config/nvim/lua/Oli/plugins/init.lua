local present, packer = pcall(require, config_namespace .. ".plugins.packer")
if not present then
  return false
end

return packer.startup({
  function(use, use_rocks)
    ----------------------------------AUTOLOAD---------------------------------- {{{
    use_rocks("penlight")
    use({
      "wbthomason/packer.nvim",
      opt = "true",
    })
    use({
      "nathom/filetype.nvim", -- Replace default filetype.vim which is slower
    })
    use({
      "tpope/vim-sleuth", -- Automatically detects which indents should be used in the current buffer
    })
    use({
      "nvim-lua/plenary.nvim", -- Required dependency for many plugins. Super useful Lua functions
    })
    use({
      "antoinemadec/FixCursorHold.nvim", -- Fix neovim CursorHold and CursorHoldI autocmd events performance bug
    })
    use({
      "lewis6991/impatient.nvim", -- Speeds up load times
    })
    ---------------------------------------------------------------------------- }}}
    ---------------------------------APPEARANCE--------------------------------- {{{
    use({
      --"olimorris/onedarkpro.nvim",
      "~/Code/Projects/onedarkpro.nvim", -- My onedarkpro theme
      as = "onedarkpro",
      config = function()
        require(config_namespace .. ".plugins.theme").setup()
      end,
    })
    use({
      "goolord/alpha-nvim", -- Dashboard for Neovim
      after = "onedarkpro",
      config = function()
        require(config_namespace .. ".plugins.dashboard").setup()
      end,
    })
    use({
      "feline-nvim/feline.nvim", -- Statusline
      after = "onedarkpro",
      requires = {
        { "kyazdani42/nvim-web-devicons" }, -- Web icons for various plugins
      },
      config = function()
        require(config_namespace .. ".plugins.statusline").setup()
      end,
    })
    use({
      "noib3/cokeline.nvim", -- Bufferline
      after = "onedarkpro",
      config = function()
        require(config_namespace .. ".plugins.bufferline").setup()
      end,
    })
    use({
      "famiu/bufdelete.nvim", -- Easily close buffers whilst preserving your window layouts
      cmd = { "Bdelete", "Bwipeout" },
    })
    use({
      "lewis6991/gitsigns.nvim", -- Git signs in the sign column
      config = function()
        require(config_namespace .. ".plugins.gitsigns")
      end,
    })
    use({
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
    })
    use({
      "stevearc/dressing.nvim", -- Utilises Neovim 0.6's new UI hooks to manage inputs, selects etc
      config = function()
        require(config_namespace .. ".plugins.others").dressing()
      end,
    })
    use({
      "norcalli/nvim-colorizer.lua", -- Highlight hex and rgb colors within Neovim
      cmd = { "Colorizer*" },
      config = function()
        require(config_namespace .. ".plugins.others").colorizer()
      end,
    })
    use({
      "lukas-reineke/headlines.nvim", -- Highlight headlines and code blocks in Markdown
      ft = "markdown",
      config = function()
        require(config_namespace .. ".plugins.others").headlines()
      end,
    })
    use({
      "wfxr/minimap.vim", -- Display a minimap
      cmd = { "MinimapToggle", "Minimap", "MinimapRefresh" },
      config = function()
        require(config_namespace .. ".plugins.others").minimap()
      end,
    })
    use({
      "lukas-reineke/indent-blankline.nvim", -- Show indentation lines
      config = function()
        require(config_namespace .. ".plugins.others").indentline()
      end,
    })
    use({
      "petertriho/nvim-scrollbar", -- A scrollbar for the current window
      after = "onedarkpro",
      requires = {
        {
          "kevinhwang91/nvim-hlslens", -- Highlight searches
        },
        {
          "declancm/cinnamon.nvim", -- Smooth scrolling
          config = function()
            require(config_namespace .. ".plugins.others").cinnamon()
          end,
        },
      },
      config = function()
        require(config_namespace .. ".plugins.others").scrollbar()
      end,
    })
    use({
      "stevearc/qf_helper.nvim", -- Improves the quickfix and location list windows
      config = function()
        require(config_namespace .. ".plugins.others").qf_helper()
      end,
    })
    use({
      "folke/todo-comments.nvim", -- Highlight and search for todo comments within the codebase
      config = function()
        require(config_namespace .. ".plugins.others").todo_comments()
      end,
    })
    use({
      "SmiteshP/nvim-navic", -- Winbar component showing current code context
      requires = "neovim/nvim-lspconfig",
      config = function()
        require(config_namespace .. ".plugins.others").nvim_navic()
      end,
    })
    ---------------------------------------------------------------------------- }}}
    -------------------------------EDITOR FEATURES------------------------------ {{{
    use({
      "williamboman/mason.nvim", -- Easily install and manage LSP servers, DAP servers, linters, and formatters
      config = function()
        require(config_namespace .. ".plugins.others").mason()
      end,
    })
    use({
      -- "olimorris/persisted.nvim", -- Session management
      "~/Code/Projects/persisted.nvim",
      module = "persisted",
      config = function()
        require(config_namespace .. ".plugins.others").persisted()
        require("telescope").load_extension("persisted")
      end,
    })
    use({
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
          after = "telescope.nvim",
          config = function()
            require(config_namespace .. ".plugins.others").harpoon()
            require("telescope").load_extension("harpoon")
          end,
        },
        {
          "stevearc/aerial.nvim", -- Toggled list of classes, methods etc in current file
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
      "mbbill/undotree", -- Visually see your undos
      cmd = "UndotreeToggle",
      config = function()
        require(config_namespace .. ".plugins.others").undotree()
      end,
    })
    use({
      "VonHeikemen/searchbox.nvim", -- Search box in the top right corner
      requires = {
        { "MunifTanjim/nui.nvim" },
      },
      config = function()
        require(config_namespace .. ".plugins.others").search()
      end,
    })
    use({
      "phaazon/hop.nvim", -- Speedily navigate anywhere in a buffer
      config = function()
        require(config_namespace .. ".plugins.others").hop()
      end,
    })
    use({
      "akinsho/nvim-toggleterm.lua", -- Easily toggle and position the terminal
      config = function()
        require(config_namespace .. ".plugins.others").toggleterm()
      end,
    })
    use({
      "mrjones2014/legendary.nvim", -- A legend for all keymaps, commands and autocmds
      config = function()
        require(config_namespace .. ".plugins.legendary").setup()
      end,
    })
    use({
      "fedepujol/move.nvim", -- Move lines and blocks
    })
    ---------------------------------------------------------------------------- }}}
    ---------------------------------COMPLETION--------------------------------- {{{
    use({
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
    })
    ---------------------------------------------------------------------------- }}}
    -----------------------------------CODING----------------------------------- {{{
    -------------------------------------LSP------------------------------------ {{{
    use({
      "williamboman/mason-lspconfig.nvim", -- Install LSP servers from within Neovim
      after = "mason.nvim",
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
    })
    use({
      "jose-elias-alvarez/null-ls.nvim", -- General language server for linting, formatting etc
      after = "mason-lspconfig.nvim",
      config = function()
        require(config_namespace .. ".plugins.null-ls")
      end,
    })
    use({
      "andrewferrier/textobj-diagnostic.nvim",
      config = function()
        require(config_namespace .. ".plugins.others").textobj_diagnostic()
      end,
    })
    ---------------------------------------------------------------------------- }}}
    ---------------------------------TREESITTER--------------------------------- {{{
    use({
      "nvim-treesitter/nvim-treesitter", -- Smarter code understanding like syntax Highlight and navigation
      run = ":TSUpdate",
      requires = {
        {
          "windwp/nvim-ts-autotag", -- Autoclose and autorename HTML and Vue tags
        },
        {
          "windwp/nvim-autopairs", -- Autopair plugin
          config = function()
            require(config_namespace .. ".plugins.others").nvim_autopairs()
          end,
        },
        {
          "JoosepAlviste/nvim-ts-context-commentstring", -- Smart commenting in multi language files - Enabled in Treesitter file
        },
        {
          "David-Kunz/treesitter-unit", -- Better selection of Treesitter code
        },
        {
          "RRethy/nvim-treesitter-endwise", -- add "end" in Ruby and other languages
        },
        {
          "nvim-treesitter/nvim-treesitter-textobjects", -- Syntax aware text-objects, select, move, swap, and peek support.
        },
        {
          "m-demare/hlargs.nvim", -- Highlight argument definitions
          config = function()
            require(config_namespace .. ".plugins.others").hlargs()
          end,
        },
        {
          "abecodes/tabout.nvim", -- Tab out from parenthesis, quotes, brackets...
          after = "nvim-cmp",
          config = function()
            require(config_namespace .. ".plugins.others").tabout()
          end,
        },
      },
      config = function()
        require(config_namespace .. ".plugins.treesitter")
      end,
    })
    use({
      "nvim-treesitter/playground", -- View Treesitter definitions
      cmd = { "TSPlaygroundToggle", "TSHighlightCapturesUnderCursor" },
    })
    ---------------------------------------------------------------------------- }}}
    -----------------------------------TESTING---------------------------------- {{{
    use({
      "nvim-neotest/neotest",
      requires = {
        "~/Code/Projects/neotest-rspec",
        "~/Code/Projects/neotest-phpunit",
        "nvim-neotest/neotest-plenary",
        "nvim-neotest/neotest-python",
        "antoinemadec/FixCursorHold.nvim",
      },
      config = function()
        require(config_namespace .. ".plugins.others").neotest()
      end,
    })
    use({
      "andythigpen/nvim-coverage", -- Display test coverage information
      module = "coverage",
      config = function()
        require(config_namespace .. ".plugins.others").coverage()
      end,
    })
    ---------------------------------------------------------------------------- }}}
    ----------------------------------DEBUGGING--------------------------------- {{{
    use({
      "mfussenegger/nvim-dap", -- Debug Adapter Protocol for Neovim
      requires = {
        "theHamsta/nvim-dap-virtual-text", -- help to find variable definitions in debug mode
        "rcarriga/nvim-dap-ui", -- Nice UI for nvim-dap
      },
      config = function()
        require(config_namespace .. ".plugins.dap").setup()
      end,
    })
    ---------------------------------------------------------------------------- }}}
    -----------------------------------OTHERS----------------------------------- {{{
    use({
      "ThePrimeagen/refactoring.nvim",
      after = "telescope.nvim",
      requires = {
        { "nvim-lua/plenary.nvim" },
        { "nvim-treesitter/nvim-treesitter" },
      },
      config = function()
        require(config_namespace .. ".plugins.others").refactoring()
      end,
    })
    use({
      "github/copilot.vim", -- AI programming
      config = function()
        require(config_namespace .. ".plugins.others").copilot()
      end,
    })
    use({
      "kylechui/nvim-surround", -- Use vim commands to surround text, tags with brackets, parenthesis etc
      config = function()
        require(config_namespace .. ".plugins.others").nvim_surround()
      end,
    })
    use({
      "numToStr/Comment.nvim", -- Comment out lines with gcc
      config = function()
        require(config_namespace .. ".plugins.others").comment()
      end,
    })
    use({
      "pianocomposer321/yabs.nvim", -- Build and run your code
      module = "yabs",
      config = function()
        require(config_namespace .. ".plugins.others").yabs()
      end,
    })
    ---------------------------------------------------------------------------- }}}
    ---------------------------------------------------------------------------- }}}
    ------------------------------------MISC------------------------------------ {{{
    use({
      "ahmedkhalf/project.nvim", -- Automatically set the cwd to the project root
      config = function()
        require(config_namespace .. ".plugins.others").project_nvim()
      end,
    })
    use({
      "stevearc/stickybuf.nvim", -- Ensure buffers are not opened in certain filetypes
      config = function()
        require(config_namespace .. ".plugins.others").stickybuf()
      end,
    })
    use({
      "nathom/tmux.nvim", -- Navigate Tmux panes inside of neovim
      cond = function()
        return os.getenv("TMUX")
      end,
    })
    use({
      "dstein64/vim-startuptime", -- Profile your Neovim startup time
      cmd = "StartupTime",
      config = function()
        vim.g.startuptime_tries = 15
        vim.g.startuptime_exe_args = { "+let g:auto_session_enabled = 0" }
      end,
    })
    ---------------------------------------------------------------------------- }}}
    ------------------------------PACKER BOOTSTRAP------------------------------ {{{
    if PACKER_BOOTSTRAP then
      require("packer").sync()
    end
    ---------------------------------------------------------------------------- }}}
  end,
})
