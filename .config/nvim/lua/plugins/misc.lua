local M = {}
local opts = {silent = true}
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
        closable = true,

        icons = false, -- Webdev icons
        icon_close_tab = '',

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
-------------------------------------DAP------------------------------------ {{{
function M.dap()
    if pcall(cmd, 'packadd nvim-dap') then
 
        cmd 'packadd nvim-dap'
        
        if pcall(cmd, 'packadd nvim-dap-virtual-text') then
            cmd 'packadd nvim-dap-virtual-text'
            g.dap_virtual_text = true
        end

        fn.sign_define('DapBreakpoint', {
            text = '',
            texthl = 'DebugBreakpoint',
            linehl = '',
            numhl = 'DebugBreakpoint'
        })
        fn.sign_define('DapStopped', {
            text = '',
            texthl = 'DebugHighlight',
            linehl = '',
            numhl = 'DebugHighlight'
        })

        if pcall(require, 'telescope') and pcall(cmd, 'packadd telescope-dap.nvim') then

            cmd 'packadd telescope-dap.nvim'
    
            local dap = require('telescope').load_extension('dap')

            local options = {
                shorten_path = false,
                height = 3,
                layout_config = {
                    preview_width = 0.6
                }
            }
            function _G.__telescope_breakpoints()
                dap.list_breakpoints(options)
            end
        end
    end
end
-- Call this function when a dap event is launched via jobstart
local function dap_on_event(job_id, data, event)
    -- Log any output from the job
    if event == "stdout" or event == "stderr" then
        if data then
            vim.list_extend(debug_info, data)
        end
    end

    -- Alert the user to an error whilst running
    if event == "stderr" then
        utils.echo_error('Error debugging. Please run :copen')
    end

    if event == "exit" then
        -- Disconect the adapter and clear the global variables
        require('dap').disconnect()
        g.debug_job_id = nil

        -- Write the output from the job to the quickfix window
        fn.setqflist({}, " ", {
            title = 'Debugging',
            lines = debug_info
        })

        utils.echo_info('Debugging stopped.')
    end
end

utils.map_lua('n', '<F1>', 'require\'dap\'.toggle_breakpoint()', opts)
utils.map_lua('n', '<F2>', 'require\'dap\'.continue()', opts)
utils.map_lua('n', '<F3>', 'require\'dap\'.step_into()', opts)
utils.map_lua('n', '<F4>', 'require\'dap\'.step_over()', opts)
utils.map_lua('n', '<F5>', 'require\'dap\'.repl.toggle({height = 6})', opts)
utils.map_lua('n', '<F6>', '__telescope_breakpoints()', opts)
utils.map_lua('n', '<F12>', 'require\'dap\'.run_last()', opts)
---------------------------------------------------------------------------- }}}
----------------------------------DASHBOARD--------------------------------- {{{
function M.dashboard()
    g.dashboard_default_executive = 'telescope'
    g.dashboard_session_directory = sessiondir

    g.dashboard_preview_command = 'cat'
    g.dashboard_preview_pipeline = 'lolcat'
    g.dashboard_preview_file = homedir .. '/.config/nvim/static/neovim.cat'
    g.dashboard_preview_file_height = 8
    g.dashboard_preview_file_width = 90

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
        }
        -- f = {
        --     description = {'  Marks                   '},
        --     command = 'Telescope marks'
        -- }
    }
    g.dashboard_custom_footer = {"[ Oli's Dashboard ]"}

    cmd ':ab db Dashboard'
end
---------------------------------------------------------------------------- }}}
-------------------------------------HOP------------------------------------ {{{
utils.map('n', '$', "<cmd>lua require'hop'.hint_words()<CR>")
---------------------------------------------------------------------------- }}}
---------------------------------INDENTLINE--------------------------------- {{{
function M.indentline()
    g.indent_blankline_char = '┊'
    g.indent_blankline_use_treesitter = true
    g.indent_blankline_show_current_context = true
    g.indent_blankline_space_char_highlight_list = 'Whitespace'
    g.indent_blankline_show_first_indent_level = false

    g.indent_blankline_buftype_exclude = {'terminal', 'nofile'}
    g.indent_blankline_filetype_exclude = {'help', 'markdown', 'gitcommit', 'startify', 'dashboard', 'packer'}
    -- g.indent_blankline_show_trailing_blankline_indent = false
end
---------------------------------------------------------------------------- }}}
----------------------------------NVIM-TREE--------------------------------- {{{
function M.nvim_tree()
    g.nvim_tree_indent_markers = 1
    g.nvim_tree_auto_ignore_ft = {'startify', 'dashboard', 'floaterm'}
    g.nvim_tree_ignore = {'.git', 'node_modules', '.pytest_cache', '.vim', '.vscode', '.cache', '.DS_Store',
                          '__pycache__'}

    utils.map('n', '<C-b>', '<cmd>NvimTreeToggle<CR>', opts)
    utils.map('n', '<C-z>', '<cmd>NvimTreeFindFile<CR>', opts)
end
---------------------------------------------------------------------------- }}}
--------------------------------PROJECT ROOT-------------------------------- {{{
function M.projectroot()
    g.rootmarkers = {'.projectroot', '.git', '.env', '.env.dev', 'pyproject.toml', 'package.json'}

    utils.create_augroup(
        {{'VimEnter * silent! ProjectRootCD'} -- Automatically set the current working directory to the Project Root
        }, 'set_cwd')
    utils.map('n', '<Leader>cd', '<cmd>ProjectRootCD<CR>', opts)
end
---------------------------------------------------------------------------- }}}
---------------------------------PROSESSION--------------------------------- {{{
function M.prosession()
    g.prosession_on_startup = 0 -- Autoload sessions
    g.prosession_per_branch = 1 -- Sessions per Git branch
    g.prosession_dir = sessiondir

    utils.map('n', '<Leader>se', '<cmd>Prosession .<CR>', opts)
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
----------------------------------VIM-TEST---------------------------------- {{{
    g['test#strategy'] = 'floaterm'

    -- Python
    g['test#python#runner'] = 'pytest'
    g['test#python#pytest#options'] = '--color=yes'
    g['test#python#pytest#executable'] = 'docker-compose -f "./docker-compose.yml" exec -T -w /usr/src/app web pytest'

    -- Javascript
    g['test#javascript#runner'] = 'jest'
    g['test#javascript#jest#options'] = '--color=always'

    utils.map('n', '<Leader>t', '<cmd>TestNearest<CR>', opts)
    utils.map('n', '<Leader>tl', '<cmd>TestLast<CR>', opts)
    utils.map('n', '<Leader>tf', '<cmd>TestFile<CR>', opts)
---------------------------------------------------------------------------- }}}
----------------------------------FLOATERM---------------------------------- {{{
    g.floaterm_width = 0.8
    g.floaterm_height = 0.8
    g.floaterm_autoinsert = true
    g.floaterm_shell = 'zsh'

    utils.map('n', '<C-x>', '<cmd>FloatermToggle<CR>', opts)
    utils.map('t', '<C-x>', '<cmd>FloatermToggle<CR>', opts)
---------------------------------------------------------------------------- }}}
-----------------------------------ULTEST----------------------------------- {{{
    if pcall(cmd, 'packadd vim-ultest') then
        cmd 'packadd vim-ultest'

        g.ultest_pass_sign = ''
        g.ultest_fail_sign = ''
        g.ultest_running_sign = 'ﱤ'
        utils.create_augroup({{'BufWritePost * UltestNearest'}}, 'ultest_runner')

        local dap = require('dap')
        dap.set_log_level('DEBUG')

        -- START: Local debugging
        dap.adapters.python = {
            type = 'executable';
            command = '/Users/Oli/.asdf/shims/python';
            args = { '-m', 'debugpy.adapter' };
        }
        dap.configurations.python = {
            type = 'python'; -- the type here established the link to the adapter definition: `dap.adapters.python`
            request = 'launch';
            name = "Launch file";
            pythonPath = '/Users/Oli/.asdf/shims/python'
        }
        -- END

        -- START: Docker debugging
        -- dap.adapters.python = {
        --     type = "server",
        --     host = '0.0.0.0',
        --     port = 5678,
        -- }
        -- END

        g['test#python#pytest#executable'] = 'pytest'

        require("ultest").setup({
            builders = {
                ['python#pytest'] = function(cmd)
                    
                    -- START: Local debugging
                    return {
                        dap = {
                            type = 'python',
                            request = 'launch',
                            module = cmd[1],
                        }
                    }
                    -- END

                    -- START: Docker debugging
                    -- local docker_cmd =
                    --     'docker-compose -f "./docker-compose.yml" exec -d -w /usr/src/app debug python -m debugpy --listen 0.0.0.0:5678 --wait-for-client -m ' ..
                    --     table.concat(cmd, " ")

                    -- utils.echo_info("Debugging.")
                    -- g.debug_job_id = fn.system(docker_cmd)

                    -- return {
                    --     dap = {
                    --         type = "python",
                    --         request = "attach",
                    --         connect = {
                    --             port = 5678,
                    --             host = '0.0.0.0'
                    --         };
                    --         mode = "remote",
                    --         name = "Remote Attached Debugger",
                    --         cwd = fn.getcwd(),
                    --         pathMappings = {
                    --             {
                    --                 localRoot = fn.getcwd(), -- Wherever your Python code lives locally.
                    --                 remoteRoot = "/usr/src/app", -- Wherever your Python code lives in the container.
                    --             };
                    --         };
                    --     }
                    -- }
                    -- END
                end
            }
        })

        utils.map('n', '<Leader>u', '<cmd>UltestNearest<CR>', opts)
        utils.map('n', '<Leader>ta', '<cmd>Ultest<CR>', opts)
        utils.map('n', '<Leader>d', '<cmd>UltestDebugNearest<CR>', opts)

    end
---------------------------------------------------------------------------- }}}
end
---------------------------------------------------------------------------- }}}
return M
