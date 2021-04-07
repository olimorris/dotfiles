---------------------------------- INSTALL --------------------------------- {{{
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    vim.api.nvim_command('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end
cmd 'autocmd BufWritePost plugins/init.lua PackerCompile' -- Auto compile when there are changes in plugins.lua
---------------------------------------------------------------------------- }}}
----------------------------------COMMANDS---------------------------------- {{{
cmd ':ab ps PackerSync'
cmd ':ab pc PackerCompile'
cmd ':ab pi PackerInstall'
---------------------------------------------------------------------------- }}}
---------------------------------- PLUGINS --------------------------------- {{{
return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

    -- Appearance
    use {
        'olimorris/onedark.nvim',
        requires = 'rktjmp/lush.nvim'
    }
    use {
        'romgrk/barbar.nvim', -- Tabline
        event = {'VimEnter *'},
        config = require('plugins.misc').bufferline(),
        requires = {
            'kyazdani42/nvim-web-devicons',
            opt = true
        }
    }
    use {
        'dstein64/nvim-scrollview', -- Scrollbars in Neovim
        event = {'VimEnter *'},
        config = require('plugins.misc').scrollview()
    }
    use {
        'lewis6991/gitsigns.nvim', -- Git signs in the signcolumn
        event = {'BufReadPre *', 'BufNewFile *'},
        config = require('plugins.gitsigns').setup(),
        requires = {'nvim-lua/plenary.nvim'}
    }
    use {
        'glepnir/galaxyline.nvim', -- Status line written in Lua
        branch = 'main',
        event = {'VimEnter *'},
        requires = {
            'kyazdani42/nvim-web-devicons',
            opt = true
        },
        config = function()
            require('plugins.statusline')
        end
    }
    use {
        'lukas-reineke/indent-blankline.nvim', -- Show indentation lines
        branch = 'lua',
        event = {'BufReadPre *', 'BufNewFile *'},
        config = require('plugins.misc').indentline()
    }
    use {
        'kyazdani42/nvim-tree.lua', -- File explorer
        setup = require('plugins.misc').nvim_tree(),
        requires = {
            'kyazdani42/nvim-web-devicons',
            opt = true
        }
    }
    use {
        'glepnir/dashboard-nvim', -- Beautiful dashboard upon opening Neovim
        config = require('plugins.misc').dashboard()
    }

    -- LSP
    use {
        'neovim/nvim-lspconfig', -- Use native LSP
        requires = {use {'kabouzeid/nvim-lspinstall'}, -- Install LSP servers from within Neovim
        use {
            'hrsh7th/nvim-compe', -- Code completion
            event = {'InsertEnter *'},
            config = require('plugins.compe').config()
        }},
        setup = require('plugins.lsp').setup(),
        config = require('plugins.lsp').config()
    }
    use {
        'hrsh7th/vim-vsnip', -- Snippet management
        requires = {{'hrsh7th/vim-vsnip-integ'}, -- Snippet completion and expansion
        {'rafamadriz/friendly-snippets'} -- Collection of snippets
        }
    }
    use 'glepnir/lspsaga.nvim' -- Async finder, code action, hover docs -- cool hover menus
    use 'onsails/lspkind-nvim' -- VSCode like icons in menu
    use 'kosayoda/nvim-lightbulb' -- Use VSCode lightbulb hint

    -- Treesitter
    use {
        'nvim-treesitter/nvim-treesitter',
        event = {'BufRead *'},
        requires = {{
            'nvim-treesitter/nvim-treesitter-refactor',
            after = 'nvim-treesitter'
        }, {
            'nvim-treesitter/nvim-treesitter-textobjects',
            after = 'nvim-treesitter'
        }, {
            'nvim-treesitter/playground', -- Test Treesitter on files
            after = 'nvim-treesitter'
        }, {
            'windwp/nvim-ts-autotag', -- Autoclose and autorename HTML and Vue tags
            after = 'nvim-treesitter'
        }},
        -- Use TSInstallFromGrammar to install things like python, vue, javascript etc
        config = require('plugins.treesitter').config()
    }

    -- Coding
    use {
        'nvim-telescope/telescope.nvim', -- Awesome fuzzy finder for everything
        setup = require('plugins.telescope').setup(),
        config = require('plugins.telescope').config(),
        requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}, {
            'nvim-telescope/telescope-frecency.nvim', -- Uses an algorithm to detect which files you may wish to open
            requires = 'tami5/sql.nvim',
            after = 'telescope.nvim'
        }}
    }
    use {
        'rcarriga/vim-ultest', -- Run tests on any type of code base
        requires = {{'vim-test/vim-test'}, -- Seemless running of tests within neovim
        {'voldikss/vim-floaterm'} -- Use the terminal in a floating window
        },
        run = ':UpdateRemotePlugins',
        config = require('plugins.misc').testing()
    }
    use 'tpope/vim-surround' -- Use vim commands to surround text, tags with brackets, parenthesis etc
    use {
        'nacro90/numb.nvim', -- Peak on line numbers
        setup = require('numb').setup()
    }
    use {
        'windwp/nvim-autopairs', -- Pair brackets, quotation marks etc
        event = {'BufRead *'},
        setup = function()
            cmd 'packadd nvim-autopairs'
            require('nvim-autopairs').setup()
        end
    }
    use {
        'mfussenegger/nvim-dap', -- Debug Adapter Protocol for Neovim
        opt = true,
        ft = {'python'}, -- Specify filetypes which load this plugin
        requires = {{
            'mfussenegger/nvim-dap-python', -- Easy Python debugging
            opt = true
        }, {
            'theHamsta/nvim-dap-virtual-text', -- help to find variable definitions in debug mode
            opt = true,
            after = 'nvim-treesitter'
        }, {
            'nvim-telescope/telescope-dap.nvim',
            opt = true,
            after = 'telescope.nvim'
        }},
        setup = require('plugins.dap').setup(),
        config = require('plugins.dap').config()
    }
    use 'phaazon/hop.nvim' -- EasyMotion like plugin to jump anywhere in a document
    use 'tweekmonster/django-plus.vim' -- Django support
    use {
        'JoosepAlviste/nvim-ts-context-commentstring', -- Smart commenting in multi language files - Enabled in Treesitter file
        requires = {
            'terrortylor/nvim-comment',
            config = require('nvim_comment').setup()
        }
    }

    -- Misc plugins
    use {
        'christoomey/vim-tmux-navigator', -- Navigate Tmux panes inside of neovim
        cond = function()
            return os.getenv('TMUX')
        end,
        setup = function()
            cmd 'packadd vim-tmux-navigator'
        end
    }
    use {
        'dhruvasagar/vim-prosession', -- Sessions per Git branch, easy session switching and also auto-starts sessions
        config = require('plugins.misc').prosession(),
        requires = 'tpope/vim-obsession' -- Continuously update session files
    }

    use {
        'dbakker/vim-projectroot', -- Detect the project root of a folder
        config = require('plugins.misc').projectroot()
    }
    use {
        '907th/vim-auto-save', -- Autosave buffers
        config = require('plugins.misc').autosave()
    }
end)
---------------------------------------------------------------------------- }}}
