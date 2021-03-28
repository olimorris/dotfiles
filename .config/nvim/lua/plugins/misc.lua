local M = {}
----------------------------------AUTOSAVE---------------------------------- {{{
function M.autosave()
    g.auto_save = 0
    g.auto_save_silent = 0
end
---------------------------------------------------------------------------- }}}
---------------------------------BUFFERLINE--------------------------------- {{{
function M.bufferline()
    g.bufferline = {
        animation = false,
        auto_hide = false,
        clickable = false,
        closable = false,

        icons = false, -- Webdev icons
        icon_separator_active = '▎',
        icon_separator_inactive = '▎',
        icon_close_tab = '',
        icon_close_tab_modified = '',

        maximum_padding = 1
    }
    utils.map('n', '<C-c>', '<cmd>BufferWipeout!<CR>', {
        silent = true
    })
    utils.map('n', '<Tab>', '<cmd>BufferNext<CR>', {
        silent = true
    })
    utils.map('n', '<s-Tab>', '<cmd>BufferPrevious<CR>', {
        silent = true
    })
end
---------------------------------------------------------------------------- }}}
-----------------------------------COMMENT---------------------------------- {{{
function M.comment()
    local has_plugin = pcall(cmd, 'packadd nvim_comment')
    if not has_plugin then
        do
            return
        end
    end
    require('nvim_comment').setup()
end
---------------------------------------------------------------------------- }}}
----------------------------------DASHBOARD--------------------------------- {{{
function M.dashboard()
    local home = os.getenv('HOME')
    
    g.dashboard_default_executive = 'telescope'
    g.dashboard_session_directory = sessiondir

    g.dashboard_preview_command = 'cat'
    g.dashboard_preview_pipeline = 'lolcat'
    g.dashboard_preview_file = home .. '/.config/nvim/static/neovim.cat'
    g.dashboard_preview_file_height = 8
    g.dashboard_preview_file_width = 80

    g.dashboard_custom_section = {
        a = {
            description = {'  Start / Load Session    '},
            command = 'Prosession .'
        },
        b = {
            description = {'  Recently Opened Files   '},
            command = 'Telescope oldfiles'
        },
        c = {
            description = {'  Find File               '},
            command = 'Telescope find_files find_command=rg,--hidden,--files'
        },
        e = {
            description = {'  Find Word               '},
            command = 'Telescope live_grep'
        },
        -- f = {
        --     description = {'  Marks                   '},
        --     command = 'Telescope marks'
        -- }
    }
    g.dashboard_custom_footer = { "[ Oli's Dashboard ]"}

    cmd ':ab db Dashboard'
end
---------------------------------------------------------------------------- }}}
-------------------------------------HOP------------------------------------ {{{
utils.map('n', '$', "<cmd>lua require'hop'.hint_words()<cr>", {})
---------------------------------------------------------------------------- }}}
---------------------------------INDENTLINE--------------------------------- {{{
function M.indentline()
    g.indent_blankline_char = ' '
    g.indent_blankline_use_treesitter = true
    g.indent_blankline_show_current_context = true
    g.indent_blankline_space_char_highlight_list = 'IndentLine'
    g.indent_blankline_show_first_indent_level = false

    g.indent_blankline_buftype_exclude = {'terminal'}
    g.indent_blankline_filetype_exclude = {'help', 'startify', 'dashboard', 'packer'}
    -- g.indent_blankline_show_trailing_blankline_indent = false
end
---------------------------------------------------------------------------- }}}
----------------------------------NVIM-TREE--------------------------------- {{{
function M.nvim_tree()
    g.nvim_tree_indent_markers = 1
    g.nvim_tree_auto_ignore_ft = {'startify', 'dashboard', 'floaterm'}
    g.nvim_tree_ignore = {'.git', 'node_modules', '.pytest_cache', '.vim', '.vscode', '.cache', '.DS_Store',
                          '__pycache__'}

    utils.map('n', '<C-b>', '<cmd>NvimTreeToggle<CR>', {
        silent = true
    })
    utils.map('n', '<C-z>', '<cmd>NvimTreeFindFile<CR>', {
        silent = true
    })
end
---------------------------------------------------------------------------- }}}
--------------------------------PROJECT ROOT-------------------------------- {{{
function M.projectroot()
    g.rootmarkers = {'.projectroot', '.git', '.env', '.env.dev', 'pyproject.toml', 'package.json'}

    utils.create_augroup(
        {{'BufEnter * silent! ProjectRootCD'} -- Automatically set the current working directory to the Project Root
        }, 'SetPWD')
    utils.map('n', '<Leader>cd', '<cmd>ProjectRootCD<CR>')
end
---------------------------------------------------------------------------- }}}
---------------------------------PROSESSION--------------------------------- {{{
function M.prosession()
    g.prosession_on_startup = 0 -- Autoload sessions
    g.prosession_per_branch = 1 -- Sessions per Git branch
    g.prosession_dir = sessiondir

    utils.map('n', '<Leader>se', '<cmd>Prosession .<CR>', {
        silent = true
    })
    cmd ':ab Pro Prosession .'
    cmd ':ab pro Prosession .'
end
---------------------------------------------------------------------------- }}}
--------------------------------SCROLL VIEW--------------------------------- {{{
g.scrollview_excluded_filetypes = {'NvimTree', 'floaterm'}
function M.scrollview()
    cmd 'highlight link ScrollView Pmenu'
end
---------------------------------------------------------------------------- }}}
----------------------------------STARTIFY---------------------------------- {{{
function M.startify()
    g.startify_session_dir = sessiondir

    g.startify_lists = {{
        type = 'sessions',
        header = {'   Sessions'}
    }, {
        type = 'files',
        header = {'   Files'}
    }, {
        type = 'dir',
        header = {'   Files ' .. fn.getcwd()}
    }, {
        type = 'bookmarks',
        header = {'   Bookmarks'}
    }, {
        type = 'commands',
        header = {'   Commands'}
    }}
end
---------------------------------------------------------------------------- }}}
-----------------------------------TESTING---------------------------------- {{{
function M.testing()
    -- Vim Test
    g['test#strategy'] = 'floaterm'

    g['test#python#runner'] = 'pytest'
    g['test#python#pytest#options'] = '--color=yes'
    g['test#python#pytest#executable'] = 'docker-compose -f "./docker-compose.yml" exec -T -w /usr/src/app web pytest'

    g['test#javascript#runner'] = 'jest'
    g['test#javascript#jest#options'] = '--color=always'

    local DockerDebug = function(cmd)

    end
    g['test#custom_transformations'] = {docker_debug = DockerDebug()}
    g['test#transformation'] = 'docker_debug'

    -- Floaterm
    g.floaterm_width = 0.8
    g.floaterm_height = 0.8
    g.floaterm_autoinsert = true

    -- Ultest
    g.ultest_pass_sign = ''
    g.ultest_fail_sign = ''
    g.ultest_running_sign = 'ﱤ'
    utils.create_augroup({{'BufWritePost * UltestNearest'}}, 'UltestRunner')

    utils.map('n', '<Leader>t', '<cmd>TestNearest<CR>', {
        silent = true
    })
    utils.map('n', '<Leader>u', '<cmd>UltestNearest<CR>', {
        silent = true
    })
    utils.map('n', '<Leader>ta', '<cmd>Ultest<CR>', {
        silent = true
    })
    utils.map('n', '<Leader>tl', '<cmd>TestLast<CR>', {
        silent = true
    })
    utils.map('n', '<Leader>tf', '<cmd>TestFile<CR>', {
        silent = true
    })
    utils.map('n', '<C-x>', '<cmd>FloatermToggle<CR>', {
        silent = true
    })
    utils.map('t', '<C-x>', '<cmd>FloatermToggle<CR>', {
        silent = true
    })
end
---------------------------------------------------------------------------- }}}
return M
