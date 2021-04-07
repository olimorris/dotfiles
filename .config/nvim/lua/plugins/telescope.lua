local M = {}
local has_plugin = pcall(require, "telescope")
local has_frecency = pcall(cmd, "packadd telescope-frecency.nvim")

function M.setup()

    if not has_plugin then
        do
            return
        end
    end

    if has_frecency then
        cmd 'packadd telescope-frecency.nvim'
        require("telescope").load_extension("frecency")
    end

    local builtins = require('telescope.builtin')

    local options = {
        shorten_path = false,
        height = 3,
        layout_config = {
            preview_width = 0.6
        }
    }

    -- Define the Telescope methods here so options can be passed. This neatly
    -- allows for the commands to be called via Lua, in neovim
    function _G.__telescope_current_buffer_fuzzy_find()
        builtins.current_buffer_fuzzy_find(options)
    end
    function _G.__telescope_files()
        builtins.find_files(options)
    end
    function _G.__telescope_all_files()
        options['search_dirs'] = {'~/Code/Neovim', '~/Code/Python'}
        builtins.find_files(options)
    end
    function _G.__telescope_live_grep()
        builtins.live_grep(options)
    end
    function _G.__telescope_treesitter()
        builtins.treesitter(options)
    end

    local opts = {
        silent = true
    }
    utils.map_lua('n', '<C-f>', '__telescope_current_buffer_fuzzy_find()', opts)
    utils.map_lua('n', '<C-p>', '__telescope_files()', opts)
    utils.map_lua('n', '<C-o>', '__telescope_all_files()', opts)
    utils.map_lua('n', '<C-g>', '__telescope_live_grep()', opts)
    utils.map_lua('n', '<C-t>', '__telescope_treesitter()', opts)
    utils.map_lua('n', '<Leader><Leader>', 'require(\'telescope\').extensions.frecency.frecency()', opts)

end

function M.config()

    if not has_plugin then
        do
            return
        end
    end

    local actions = require('telescope.actions')
    local sorters = require('telescope.sorters')
    local previewers = require('telescope.previewers')

    require('telescope').setup {
        defaults = {
            prompt_prefix = ' 🔍 ',
            selection_caret = "ﰲ ",
            file_ignore_patterns = {"%.csv", "%.jpg", "%.jpeg", "%.png", "%.svg", "%.otf", "%.ttf", "%.lock",
                                    "__pycache__/*", "%.sqlite3", "%.ipynb", "vendor/*", "node_modules/*"},
            file_sorter = sorters.get_fzy_sorter,
            generic_sorter = sorters.get_fzy_sorter,
            file_previewer = previewers.vim_buffer_cat.new,
            grep_previewer = previewers.vim_buffer_vimgrep.new,
            qflist_previewer = previewers.vim_buffer_qflist.new,
            layout_strategy = 'flex',
            winblend = 9,
            set_env = {
                COLORTERM = "truecolor"
            },
            color_devicons = true,
            mappings = {
                i = {
                    ["<ESC>"] = actions.close,
                    ["<C-j>"] = actions.move_selection_next,
                    ["<C-k>"] = actions.move_selection_previous,
                    ["<C-q>"] = actions.send_to_qflist
                },
                n = {
                    ["<ESC>"] = actions.close
                }
            }
        },
        extensions = {
            frecency = {
              show_scores = false,
              show_unindexed = true,
              ignore_patterns = {"*.git/*", "*/tmp/*"},
              workspaces = {
                ["nvim"] = "/Users/Oli/.config/nvim",
                ["dots"] = "/Users/Oli/.dotfiles",
                ["project"] = "/Users/Oli/Code/python/UAPI/",
              }
            }
          },
    }

end

return M
