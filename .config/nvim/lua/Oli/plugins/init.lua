local present, packer = pcall(require, config_namespace .. ".plugins.packer")
if not present then return false end

return packer.startup({
  function(use, use_rocks)
    ----------------------------------AUTOLOAD---------------------------------- {{{
    use_rocks("penlight")
    use({ "wbthomason/packer.nvim", opt = "true" })
    use("tpope/vim-sleuth") -- Automatically detects which indents should be used in the current buffer
    use("nvim-lua/plenary.nvim") -- Required dependency for many plugins. Super useful Lua functions
    use("antoinemadec/FixCursorHold.nvim") -- Fix neovim CursorHold and CursorHoldI autocmd events performance bug
    use("lewis6991/impatient.nvim") -- Speeds up load times
    ---------------------------------------------------------------------------- }}}
    ---------------------------------APPEARANCE--------------------------------- {{{
    use({
      --"olimorris/onedarkpro.nvim",
      "~/Code/Projects/onedarkpro.nvim", -- My onedarkpro theme
      as = "onedarkpro",
      config = function() require(config_namespace .. ".plugins.theme") end,
    })
    use({
      "mrjones2014/legendary.nvim", -- A legend for all keymaps, commands and autocmds
      after = "dressing.nvim",
      config = function() require(config_namespace .. ".plugins.legendary") end,
    })
    use({
      "goolord/alpha-nvim", -- Dashboard for Neovim
      after = "onedarkpro",
      config = function() require(config_namespace .. ".plugins.dashboard") end,
    })
    use({
      "rebelot/heirline.nvim", -- Statusline
      after = "onedarkpro",
      requires = { "kyazdani42/nvim-web-devicons" },
      config = function() require(config_namespace .. ".plugins.statusline").setup() end,
    })
    use({
      "famiu/bufdelete.nvim", -- Easily close buffers whilst preserving your window layouts
    })
    use({
      "lewis6991/gitsigns.nvim", -- Git signs in the sign column
      config = function() require(config_namespace .. ".plugins.gitsigns") end,
    })
    use({
      "nvim-neo-tree/neo-tree.nvim",
      requires = {
        { "nvim-lua/plenary.nvim" },
        { "kyazdani42/nvim-web-devicons" },
        { "MunifTanjim/nui.nvim" },
      },
      config = function() require(config_namespace .. ".plugins.file_explorer") end,
    })
    use({
      "NvChad/nvim-colorizer.lua", -- Highlight hex and rgb colors within Neovim
      cmd = { "Colorizer*" },
      config = function() require(config_namespace .. ".plugins.others").colorizer() end,
    })
    use({
      "lukas-reineke/indent-blankline.nvim", -- Show indentation lines
      config = function() require(config_namespace .. ".plugins.others").indentline() end,
    })
    use({
      "lewis6991/satellite.nvim", -- A scrollbar for the current window
      after = "onedarkpro",
      config = function() require(config_namespace .. ".plugins.others").scrollbar() end,
    })
    use({
      "folke/todo-comments.nvim", -- Highlight and search for todo comments within the codebase
      after = "onedarkpro",
      config = function() require(config_namespace .. ".plugins.others").todo_comments() end,
    })
    use({
      "utilyre/barbecue.nvim", -- VS Code like path in winbar
      after = "onedarkpro",
      requires = {
        { "neovim/nvim-lspconfig" },
        {
          "SmiteshP/nvim-navic", -- Winbar component showing current code context
          config = function() require(config_namespace .. ".plugins.others").nvim_navic() end,
        },
      },
      config = function() require(config_namespace .. ".plugins.others").barbecue() end,
    })
    use({
      "stevearc/dressing.nvim", -- Utilises Neovim 0.6's new UI hooks to manage inputs, selects etc
      config = function() require(config_namespace .. ".plugins.others").dressing() end,
    })
    use({
      "gorbit99/codewindow.nvim",
      module = "codewindow",
      config = function() require(config_namespace .. ".plugins.others").code_window() end,
    })
    use({
      "nvim-telescope/telescope.nvim", -- Awesome fuzzy finder for everything
      requires = {
        {
          "nvim-telescope/telescope-fzf-native.nvim", -- Use fzf within Telescope
          run = "make",
          config = function() require("telescope").load_extension("fzf") end,
        },
        {
          "nvim-telescope/telescope-frecency.nvim", -- Get frequently opened files
          after = "telescope.nvim",
          requires = {
            { "tami5/sqlite.lua" },
          },
          config = function() require("telescope").load_extension("frecency") end,
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
      config = function() require(config_namespace .. ".plugins.telescope") end,
    })
    ---------------------------------------------------------------------------- }}}
    --------------------------------EDITING TEXT-------------------------------- {{{
    use({
      "phaazon/hop.nvim", -- Speedily navigate anywhere in a buffer
      config = function() require(config_namespace .. ".plugins.others").hop() end,
    })
    use({
      "cshuaimin/ssr.nvim", -- Advanced search and replace using Treesitter
      module = "ssr",
      config = function() require(config_namespace .. ".plugins.others").ssr() end,
    })
    use({
      "kylechui/nvim-surround", -- Use vim commands to surround text, tags with brackets, parenthesis etc
      config = function() require(config_namespace .. ".plugins.others").nvim_surround() end,
    })
    use({
      "numToStr/Comment.nvim", -- Comment out lines with gcc
      after = "nvim-treesitter",
      config = function() require(config_namespace .. ".plugins.others").comment() end,
    })
    use({
      "fedepujol/move.nvim", -- Move lines and blocks
    })
    ---------------------------------------------------------------------------- }}}
    -----------------------------------CODING----------------------------------- {{{
    ---------------------------------COMPLETION--------------------------------- {{{
    use({
      "hrsh7th/nvim-cmp", -- Code completion menu
      event = { "InsertEnter" },
      requires = {
        {
          "L3MON4D3/LuaSnip", -- Code snippets
          requires = {
            {
              "rafamadriz/friendly-snippets", -- Collection of code snippets across many languages
            },
            {
              "danymat/neogen", -- Generate annotations for functions
              config = function() require(config_namespace .. ".plugins.others").neogen() end,
            },
          },
          config = function()
            require(config_namespace .. ".plugins.luasnip").setup()
            require(config_namespace .. ".plugins.luasnip").snippets()
          end,
        },
        -- cmp sources --
        { "saadparwaiz1/cmp_luasnip" },
        { "hrsh7th/cmp-buffer" },
        { "hrsh7th/cmp-nvim-lua" },
        { "hrsh7th/cmp-nvim-lsp" },
        { "hrsh7th/cmp-nvim-lsp-signature-help" },
        {
          "zbirenbaum/copilot-cmp",
          config = function() require("copilot_cmp").setup() end,
        },
        { "hrsh7th/cmp-path" },
        { "hrsh7th/cmp-cmdline" },
      },
      config = function() require(config_namespace .. ".plugins.completion") end,
    })
    ---------------------------------------------------------------------------- }}}
    -------------------------------------LSP------------------------------------ {{{
    use({
      "williamboman/mason.nvim", -- Easily install and manage LSP servers, DAP servers, linters, and formatters
      requires = {
        "williamboman/mason-lspconfig.nvim", -- Install LSP servers from within Neovim
        "neovim/nvim-lspconfig", -- Use Neovim's native LSP config
        "kosayoda/nvim-lightbulb", -- VSCode style lightbulb if there is a code action available
      },
      config = function()
        require(config_namespace .. ".plugins.others").mason()
        require(config_namespace .. ".plugins.lsp")
      end,
    })
    use({
      "jayp0521/mason-null-ls.nvim", -- Automatically install null-ls servers
      requires = {
        "williamboman/mason.nvim",
        "jose-elias-alvarez/null-ls.nvim", -- General purpose LSP server for running linters, formatters, etc
      },
      after = "mason.nvim",
      config = function() require(config_namespace .. ".plugins.null-ls") end,
    })
    use({
      "andrewferrier/textobj-diagnostic.nvim", -- Easier movement between diagnostics
      after = "mason.nvim",
      config = function() require(config_namespace .. ".plugins.others").textobj_diagnostic() end,
    })
    use({
      "j-hui/fidget.nvim", -- Display LSP status messages in a floating window
      after = "mason.nvim",
      config = function() require(config_namespace .. ".plugins.others").fidget() end,
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
          config = function() require(config_namespace .. ".plugins.others").nvim_autopairs() end,
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
          "abecodes/tabout.nvim", -- Tab out from parenthesis, quotes, brackets...
          after = "nvim-cmp",
          config = function() require(config_namespace .. ".plugins.others").tabout() end,
        },
      },
      config = function() require(config_namespace .. ".plugins.treesitter") end,
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
      config = function() require(config_namespace .. ".plugins.neotest").setup() end,
    })
    use({
      "stevearc/overseer.nvim", -- Task runner and job management
      -- INFO: Overseer lazy loads itself
      config = function() require(config_namespace .. ".plugins.others").overseer() end,
    })
    use({
      "andythigpen/nvim-coverage", -- Display test coverage information
      module = "coverage",
      config = function() require(config_namespace .. ".plugins.others").coverage() end,
    })
    ---------------------------------------------------------------------------- }}}
    ----------------------------------DEBUGGING--------------------------------- {{{
    use({
      "mfussenegger/nvim-dap", -- Debug Adapter Protocol for Neovim
      module = "dap",
      requires = {
        "theHamsta/nvim-dap-virtual-text", -- help to find variable definitions in debug mode
        "rcarriga/nvim-dap-ui", -- Nice UI for nvim-dap
      },
      config = function() require(config_namespace .. ".plugins.dap") end,
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
      config = function() require(config_namespace .. ".plugins.others").refactoring() end,
    })
    use({
      "zbirenbaum/copilot.lua", -- AI programming
      event = "InsertEnter",
      config = function()
        vim.schedule(function() require(config_namespace .. ".plugins.others").copilot() end)
      end,
    })
    ---------------------------------------------------------------------------- }}}
    ---------------------------------------------------------------------------- }}}
    ------------------------------------MISC------------------------------------ {{{
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
      "ahmedkhalf/project.nvim", -- Automatically set the cwd to the project root
      config = function()
        require(config_namespace .. ".plugins.others").project_nvim()
        require("telescope").load_extension("projects")
      end,
    })
    use({
      "akinsho/nvim-toggleterm.lua", -- Easily toggle and position the terminal
      config = function() require(config_namespace .. ".plugins.others").toggleterm() end,
    })
    use({
      "kevinhwang91/nvim-bqf", -- Better quickfix window,
      ft = "qf",
    })
    use({
      "mbbill/undotree", -- Visually see your undos
      cmd = "UndotreeToggle",
      config = function() require(config_namespace .. ".plugins.others").undotree() end,
    })
    use({
      "nathom/tmux.nvim", -- Navigate Tmux panes inside of neovim
      cond = function() return os.getenv("TMUX") end,
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
    if PACKER_BOOTSTRAP then require("packer").sync() end
    ---------------------------------------------------------------------------- }}}
  end,
})
