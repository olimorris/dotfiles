----------------------------------BOOTSTRAP--------------------------------- {{{
local packer = nil
local PACKER_COMPILED_PATH = vim.fn.stdpath("cache") .. "/packer/packer_compiled.lua"
local PACKER_INSTALLED_PATH = vim.fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"

if not om.packer_installed(PACKER_INSTALLED_PATH) then
  packer = om.install_packer(PACKER_INSTALLED_PATH, PACKER_COMPILED_PATH)
else
  vim.cmd("packadd! packer.nvim")

  -- Speed up the loading of Lua modules.
  -- Eventually this plugin will be merged into the Neovim core!
  -- https://github.com/lewis6991/impatient.nvim
  om.safe_require("impatient")

  _, packer = om.safe_require("packer")
end
---------------------------------------------------------------------------- }}}
--------------------------------LOAD PLUGINS-------------------------------- {{{
------------------------------------CORE------------------------------------ {{{
packer.startup({
  function(use, use_rocks)
    use_rocks("penlight")

    use({
      "nvim-lua/plenary.nvim", -- Required dependency for many plugins. Super useful Lua functions
      lock = LockPlugins,
    })
    use({
      "wbthomason/packer.nvim",
      lock = LockPlugins,
      setup = function()
        require(config_namespace .. ".core.mappings").packer()
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
          setup = function()
            require(config_namespace .. ".core.mappings").harpoon()
          end,
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
          setup = function()
            require(config_namespace .. ".core.mappings").aerial()
          end,
          config = function()
            require("telescope").load_extension("aerial")
            require(config_namespace .. ".plugins.others").aerial()
          end,
        },
      },
      setup = function()
        require(config_namespace .. ".core.mappings").telescope()
      end,
      config = function()
        require(config_namespace .. ".plugins.telescope")
      end,
    })
    ---------------------------------------------------------------------------- }}}
    ---------------------------------APPEARANCE--------------------------------- {{{
    -- use({ "olimorris/onedarkpro.nvim" })
    -- use({
    --     "~/Code/Projects/onedarkpro.nvim",
    --     config = function()
    --         require("onedarkpro").load()
    --     end
    -- }) -- My theme
    use({ "~/Code/Projects/onedarkpro.nvim" }) -- My theme
    use({ "kyazdani42/nvim-web-devicons", lock = LockPlugins }) -- Web icons for various plugins
    use({
      "goolord/alpha-nvim", -- Dashboard for Neovim
      lock = LockPlugins,
      config = function()
        if not om.packer_just_installed then
          require(config_namespace .. ".plugins.dashboard").setup()
        end
      end,
    })
    use({
      "feline-nvim/feline.nvim", -- Lua statusline
      lock = LockPlugins,
      config = function()
        require(config_namespace .. ".plugins.statusline").setup()
      end,
    })
    use({
      "noib3/cokeline.nvim", -- Buffers in the tabline
      lock = LockPlugins,
      config = function()
        require(config_namespace .. ".core.mappings").bufferline()
        require(config_namespace .. ".plugins.bufferline").setup()
      end,
    })
    use({
      "lewis6991/gitsigns.nvim", -- Git signs in the sign column
      lock = LockPlugins,
      event = "BufRead",
      config = function()
        require(config_namespace .. ".plugins.gitsigns")
      end,
    })
    use({
      "beauwilliams/focus.nvim", -- Auto-resize splits/windows
      lock = LockPlugins,
      module = "focus",
      setup = function()
        require(config_namespace .. ".core.mappings").focus()
      end,
      config = function()
        require(config_namespace .. ".plugins.others").focus()
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
        require(config_namespace .. ".core.mappings").file_explorer()
        require(config_namespace .. ".plugins.file_explorer").setup()
      end,
      config = function()
        require(config_namespace .. ".plugins.file_explorer").config()
      end,
    })
    use({
      "norcalli/nvim-colorizer.lua", -- Highlight hex and rgb colors within Neovim
      lock = LockPlugins,
      cond = function()
        local ft = vim.bo.filetype
        return (ft == "html" or ft == "css" or ft == "lua" or ft == "javascript" or ft == "eruby")
      end,
      config = function()
        require(config_namespace .. ".plugins.others").colorizer()
      end,
    })
    use({
      "lukas-reineke/headlines.nvim", -- Highlight headlines and code blocks in Markdown
      lock = LockPlugins,
      ft = "markdown",
      config = function()
        local ok, headlines = om.safe_require("headlines")
        if ok then
          headlines.setup()
        end
      end,
    })
    use({
      "wfxr/minimap.vim", -- Display a minimap
      lock = LockPlugins,
      cmd = { "MinimapToggle", "Minimap", "MinimapRefresh" },
      setup = function()
        require(config_namespace .. ".core.mappings").minimap()
      end,
      config = function()
        require(config_namespace .. ".plugins.others").minimap()
      end,
    })
    use({
      "folke/which-key.nvim", -- Info panel containing your keybindings
      lock = LockPlugins,
      config = function()
        require(config_namespace .. ".plugins.which_key")
      end,
    })
    ---------------------------------------------------------------------------- }}}
    -------------------------------------LSP------------------------------------ {{{
    use({
      "williamboman/nvim-lsp-installer", -- Install LSP servers from within Neovim
      lock = LockPlugins,
      requires = {
        { "neovim/nvim-lspconfig", lock = LockPlugins }, -- Use Neovims native LSP config
        { "kosayoda/nvim-lightbulb", lock = LockPlugins }, -- VSCode style lightbulb if there is a code action available
      },
      config = function()
        require(config_namespace .. ".plugins.lsp")
      end,
    })
    use({
      "jose-elias-alvarez/null-ls.nvim", -- General language server to enable awesome things with the LSP
      lock = LockPlugins,
      event = "BufRead",
      config = function()
        require(config_namespace .. ".plugins.null-ls")
      end,
    })
    ---------------------------------------------------------------------------- }}}
    -------------------------------CODE COMPLETION------------------------------ {{{
    use({
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
    })
    --
    use({
      "windwp/nvim-autopairs", -- Automatically inserts a closing bracket, moustache etc
      lock = LockPlugins,
      after = "nvim-cmp",
      config = function()
        require(config_namespace .. ".plugins.others").autopairs()
      end,
    })
    ---------------------------------------------------------------------------- }}}
    -------------------------CODE MANAGEMENT/READABILITY------------------------ {{{
    use({
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
      },
      setup = function()
        require(config_namespace .. ".core.mappings").treesitter()
      end,
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
      "lukas-reineke/indent-blankline.nvim", -- Show indentation lines
      lock = LockPlugins,
      event = "BufRead",
      config = function()
        require(config_namespace .. ".plugins.others").indentline()
      end,
    })
    use({
      "pianocomposer321/yabs.nvim", -- Build and run your code
      lock = LockPlugins,
      module = "yabs",
      setup = function()
        require(config_namespace .. ".core.mappings").yabs()
      end,
      config = function()
        require(config_namespace .. ".plugins.others").yabs()
      end,
    })
    -- use({
    -- 	"chentau/marks.nvim", -- Interact with marks
    -- 	keys = "m",
    -- 	setup = function()
    -- 		require(config_namespace .. ".core.mappings").marks()
    -- 		require(config_namespace .. ".plugins.others").marks()
    -- 	end,
    -- })
    use({
      "abecodes/tabout.nvim", -- Tab out from parenthesis, quotes, brackets...
      lock = LockPlugins,
      after = "nvim-cmp",
      config = function()
        require(config_namespace .. ".plugins.others").tabout()
      end,
    })
    use({
      "mg979/vim-visual-multi", -- Multiple cursors. I didn't want to put this in...alas I am weak
      lock = LockPlugins,
      keys = "<C-e>",
      setup = function()
        require(config_namespace .. ".core.mappings").visual_multi()
      end,
      config = function()
        require(config_namespace .. ".plugins.others").visual_multi()
      end,
    })
    use({
      "mbbill/undotree", -- Visually see your undos
      lock = LockPlugins,
      cmd = "UndotreeToggle",
      setup = function()
        require(config_namespace .. ".core.mappings").undotree()
      end,
      config = function()
        require(config_namespace .. ".plugins.others").undotree()
      end,
    })
    use({
      "VonHeikemen/searchbox.nvim", -- Search box in the top right corner
      lock = LockPlugins,
      keys = { "/", "<LocalLeader>r" },
      requires = {
        { "MunifTanjim/nui.nvim", lock = LockPlugins },
      },
      config = function()
        require(config_namespace .. ".core.mappings").search()
        require(config_namespace .. ".plugins.others").search()
      end,
    })
    use({
      "tpope/vim-surround", -- Use vim commands to surround text, tags with brackets, parenthesis etc
      lock = LockPlugins,
      event = "InsertEnter",
    })
    use({
      "folke/todo-comments.nvim", -- Highlight and search for todo comments within the codebase
      lock = LockPlugins,
      event = "BufRead",
      setup = function()
        require(config_namespace .. ".core.mappings").todo_comments()
      end,
      config = function()
        require(config_namespace .. ".plugins.others").todo_comments()
      end,
    })
    use({
      "numToStr/Comment.nvim", -- Comment out lines with gcc
      lock = LockPlugins,
      keys = { "gcc", "gc" },
      config = function()
        require(config_namespace .. ".plugins.others").comment()
      end,
    })
    use({
      "phaazon/hop.nvim", -- Speedily navigate anywhere in a buffer
      lock = LockPlugins,
      keys = { "<localleader>h", "f", "F", "s" },
      config = function()
        require(config_namespace .. ".core.mappings").hop()
        require(config_namespace .. ".plugins.others").hop()
      end,
    })
    ---------------------------------------------------------------------------- }}}
    ------------------------------TESTING/DEBUGGING----------------------------- {{{
    use({
      "vim-test/vim-test", -- Run tests on any type of code base
      lock = LockPlugins,
      cmd = { "Test*" },
      setup = function()
        require(config_namespace .. ".core.mappings").vim_test()
        require(config_namespace .. ".plugins.testing").vim_test()
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
      setup = function()
        require(config_namespace .. ".core.mappings").dap()
      end,
      config = function()
        require(config_namespace .. ".plugins.others").dap()
      end,
    })
    ---------------------------------------------------------------------------- }}}
    -----------------------------------OTHERS----------------------------------- {{{
    use({
      "github/copilot.vim", -- AI programming
      lock = LockPlugins,
      cmd = "Copilot",
    })
    use({
      "AckslD/nvim-neoclip.lua", -- Clipboard history
      lock = LockPlugins,
      requires = {
        { "tami5/sqlite.lua", lock = LockPlugins },
      },
      setup = function()
        require(config_namespace .. ".core.mappings").neoclip()
      end,
      config = function()
        require(config_namespace .. ".plugins.others").neoclip()
      end,
    })
    use({
      "stevearc/qf_helper.nvim", -- Improves the quickfix and location list windows
      lock = LockPlugins,
      cmd = { "copen", "lopen", "QFToggle", "LLToggle", "QFOpen", "LLOpen" },
      setup = function()
        require(config_namespace .. ".core.mappings").qf_helper()
      end,
      config = function()
        require(config_namespace .. ".plugins.others").qf_helper()
      end,
    })
    use({
      -- "olimorris/persisted.nvim", -- Session management
      "~/Code/Projects/persisted.nvim",
      module = "persisted",
      setup = function()
        require(config_namespace .. ".core.mappings").persisted()
      end,
      config = function()
        require(config_namespace .. ".plugins.others").persisted()
      end,
    })
    use({
      "ahmedkhalf/project.nvim", -- Automatically set the cwd to the project root
      lock = LockPlugins,
      event = "BufRead",
      config = function()
        require(config_namespace .. ".plugins.others").project_nvim()
      end,
    })
    use({
      "tpope/vim-sleuth", -- Automatically detects which indents should be used in the current buffer
      lock = LockPlugins,
    })
    use({
      "akinsho/nvim-toggleterm.lua", -- Easily toggle and position the terminal
      lock = LockPlugins,
      cmd = { "ToggleTerm", "Test*" },
      setup = function()
        require(config_namespace .. ".core.mappings").toggleterm()
      end,
      config = function()
        require(config_namespace .. ".plugins.others").toggleterm()
      end,
    })
    use({
      "nathom/tmux.nvim", -- Navigate Tmux panes inside of neovim
      lock = LockPlugins,
      cond = function()
        return os.getenv("TMUX")
      end,
      setup = function()
        require(config_namespace .. ".core.mappings").tmux()
      end,
    })
    use({
      "famiu/bufdelete.nvim", -- Easily close buffers whilst preserving your window layouts
      lock = LockPlugins,
      cmd = { "Bdelete", "Bwipeout" },
      setup = function()
        require(config_namespace .. ".core.mappings").bufdelete()
      end,
    })
    use({
      "nathom/filetype.nvim", -- Replace default filetype.vim which is slower
      lock = LockPlugins,
    })
    ---------------------------------------------------------------------------- }}}
    ----------------------------------PROFILING--------------------------------- {{{
    use({
      "dstein64/vim-startuptime", -- Profile your Neovim startup time
      lock = LockPlugins,
      cmd = "StartupTime",
      config = function()
        vim.g.startuptime_tries = 15
        vim.g.startuptime_exe_args = { "+let g:auto_session_enabled = 0" }
      end,
    })
    -- TODO: this plugin will be redundant once https://github.com/neovim/neovim/pull/15436 is merged
    use({ "lewis6991/impatient.nvim", lock = LockPlugins })
    ---------------------------------------------------------------------------- }}}
    -------------------------------PACKER SETTINGS------------------------------ {{{
    if om.packer_just_installed then
      -- Upon a fresh Neovim install, automatically install and compile the plugins
      packer.sync()
    end
  end,
  log = { level = "info" },
  config = {
    compile_path = PACKER_COMPILED_PATH, -- Move to lua dir so impatient.nvim can cache it
    display = {
      open_fn = function()
        return require("packer.util").float({ border = "single" })
      end,
    },
    git = {
      clone_timeout = 600, -- Timeout for git clones (seconds)
    },
    profile = {
      enable = true,
      threshold = 1, -- the amount in ms that a plugins load time must be over for it to be included in the profile
    },
    auto_clean = true,
    compile_on_sync = true,
  },
})
---------------------------------------------------------------------------- }}}
---------------------------------------------------------------------------- }}}
----------------------------LOAD PACKER COMPILED---------------------------- {{{
if not vim.g.packer_compiled_loaded and vim.loop.fs_stat(PACKER_COMPILED_PATH) then
  om.source(PACKER_COMPILED_PATH)
  vim.g.packer_compiled_loaded = true
end
---------------------------------------------------------------------------- }}}
