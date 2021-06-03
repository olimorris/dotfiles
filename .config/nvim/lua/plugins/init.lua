---------------------------------- INSTALL --------------------------------- {{{
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    vim.api.nvim_command(
        '!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end
---------------------------------------------------------------------------- }}}
----------------------------------COMMANDS---------------------------------- {{{
cmd ':ab ps PackerSync'
cmd ':ab pc PackerCompile'
cmd ':ab pi PackerInstall'
---------------------------------------------------------------------------- }}}
---------------------------------- PLUGINS --------------------------------- {{{
return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

---------------------------------APPEARANCE--------------------------------- {{{
    -- use {'olimorris/onedark.nvim', requires = 'rktjmp/lush.nvim'}
    use {'~/Code/Projects/onedark_nvim', requires = 'rktjmp/lush.nvim'}
    use {
        'romgrk/barbar.nvim', -- Tabline
        event = {'BufReadPre *'},
        config = require('plugins.misc').bufferline(),
        requires = {'kyazdani42/nvim-web-devicons', opt = true}
    }
    use {
        'glepnir/dashboard-nvim', -- Beautiful dashboard upon opening Neovim
        config = require('plugins.misc').dashboard()
    }
    use {
        'dstein64/nvim-scrollview', -- Scrollbars in Neovim
        event = {'BufReadPre *'},
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
        requires = {'kyazdani42/nvim-web-devicons', opt = true},
        config = function() require('plugins.statusline') end
    }
    use {
        'lukas-reineke/indent-blankline.nvim', -- Show indentation lines
        branch = 'lua',
        event = {'BufReadPre *', 'BufNewFile *'},
        config = require('plugins.misc').indentline()
    }
---------------------------------------------------------------------------- }}}
--------------------------------FUNCTIONALITY------------------------------- {{{
    use {
        'kyazdani42/nvim-tree.lua', -- File explorer
        setup = require('plugins.misc').nvim_tree(),
        requires = {'kyazdani42/nvim-web-devicons', opt = true}
    }
    use {
        'nvim-telescope/telescope.nvim', -- Awesome fuzzy finder for everything
        setup = require('plugins.telescope').setup(),
        config = require('plugins.telescope').config(),
        requires = {
            {'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}, {
                'nvim-telescope/telescope-frecency.nvim', -- Uses an algorithm to detect which files you may wish to open
                requires = 'tami5/sql.nvim',
                after = 'telescope.nvim'
            }
        }
    }
    use {
        'nvim-treesitter/nvim-treesitter',
        event = {'BufRead *'},
        requires = {
            {
                'nvim-treesitter/nvim-treesitter-refactor',
                after = 'nvim-treesitter'
            },
            {
                'nvim-treesitter/nvim-treesitter-textobjects',
                after = 'nvim-treesitter'
            },{
                'windwp/nvim-ts-autotag', -- Autoclose and autorename HTML and Vue tags
                after = 'nvim-treesitter'
            }, {
                'JoosepAlviste/nvim-ts-context-commentstring', -- Smart commenting in multi language files - Enabled in Treesitter file
                after = 'nvim-treesitter',
                requires = {
                    'terrortylor/nvim-comment',
                    config = function() 
                        if(pcall(require, 'nvim_comment')) then
                            require('nvim_comment').setup()
                        end
                    end
                }
            }
        },
        -- Use TSInstallFromGrammar to install things like python, vue, javascript etc
        config = require('plugins.treesitter').config()
    }
    use {
        'neovim/nvim-lspconfig', -- Use native LSP
        event = {'BufRead *'},
        use {
            'hrsh7th/nvim-compe', -- Code completion
            event = {'InsertEnter *'},
            config = require('plugins.compe').config()
        },
        use {
            "folke/trouble.nvim",
            event = {'BufRead *'},
            requires = {'kyazdani42/nvim-web-devicons', opt = true}
        },
        use {
            'glepnir/lspsaga.nvim', -- Async finder, code action, hover docs -- cool hover menus
            event = {'BufRead *'}
        },
        use {
            'kosayoda/nvim-lightbulb', -- Use VSCode lightbulb hint
            event = {'BufRead *'}
        },
        setup = require('plugins.lsp').setup(),
        config = require('plugins.lsp').config()
    }
    use {
        'hrsh7th/vim-vsnip', -- Snippet management
        requires = {
            {'hrsh7th/vim-vsnip-integ'}, -- Snippet completion and expansion
            {'rafamadriz/friendly-snippets'} -- Collection of snippets
        }
    }
    use 'tpope/vim-surround' -- Use vim commands to surround text, tags with brackets, parenthesis etc
    use {
        'nacro90/numb.nvim', -- Peak on line numbers
        setup = function()
            if pcall(require, 'numb') then 
                require('numb').setup()
            end
        end
    }
    use {
        'windwp/nvim-autopairs', -- Pair brackets, quotation marks etc
        event = {'BufRead *'},
        setup = function()
            if pcall(cmd, 'packadd nvim-autopairs') then
                cmd 'packadd nvim-autopairs'
                require('nvim-autopairs').setup({
                    disable_filetype = { "TelescopePrompt" , "vim" },
                })
            end
        end
    }
    use 'phaazon/hop.nvim' -- EasyMotion like plugin to jump anywhere in a document
---------------------------------------------------------------------------- }}}
------------------------------TESTING/DEBUGGING----------------------------- {{{
    use {
        'mfussenegger/nvim-dap', -- Debug Adapter Protocol for Neovim
        opt = true,
        requires = {
            {
                'theHamsta/nvim-dap-virtual-text', -- help to find variable definitions in debug mode
                opt = true,
                after = 'nvim-treesitter'
            },
            {
                'nvim-telescope/telescope-dap.nvim',
                opt = true,
                after = 'telescope.nvim'
            }
        },
        setup = require('plugins.misc').dap()
    }
    use {
        'rcarriga/vim-ultest', -- Run tests on any type of code base
        requires = {
            {'vim-test/vim-test'}, -- Seemless running of tests within neovim
            {'voldikss/vim-floaterm'} -- Use the terminal in a floating window
        },
        after = 'nvim-dap',
        run = ':UpdateRemotePlugins',
        config = require('plugins.misc').testing()
    }
---------------------------------------------------------------------------- }}}
------------------------------------MISC------------------------------------ {{{
    use {
        'christoomey/vim-tmux-navigator', -- Navigate Tmux panes inside of neovim
        cond = function() return os.getenv('TMUX') end,
        setup = function() cmd 'packadd vim-tmux-navigator' end
    }
    use {
        'dhruvasagar/vim-prosession', -- Sessions per Git branch, easy session switching and also auto-starts sessions
        config = require('plugins.misc').prosession(),
        requires = 'tpope/vim-obsession' -- Continuously update session files
    }
    use 'ahmedkhalf/lsp-rooter.nvim' -- Automatically set the cwd to the projet root
    use {
        '907th/vim-auto-save', -- Autosave buffers
        config = require('plugins.misc').autosave()
    }
---------------------------------------------------------------------------- }}}
end)
---------------------------------------------------------------------------- }}}
