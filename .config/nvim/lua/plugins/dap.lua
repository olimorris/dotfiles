local M = {}
local has_dap = pcall(cmd, 'packadd nvim-dap')
local has_dap_python = pcall(cmd, 'packadd nvim-dap-python')
local has_dap_vtext = pcall(cmd, 'packadd nvim-dap-virtual-text')
------------------------------------SETUP----------------------------------- {{{
function M.setup()
    if not has_dap or not has_dap_python or not has_dap_vtext then
        do
            return
        end
    end

    cmd 'packadd nvim-dap'
    cmd 'packadd nvim-dap-python'
    cmd 'packadd nvim-dap-virtual-text'

    g.dap_virtual_text = true
    fn.sign_define('DapBreakpoint', {
        text = '',
        texthl = 'DebugBreakpoint',
        linehl = '',
        numhl = 'DebugBreakpoint'
    })
    fn.sign_define('DapStopped', {
        text = '',
        texthl = 'DebugHighlight',
        linehl = 'DebugHighlight',
        numhl = 'DebugHighlight'
    })
end
---------------------------------------------------------------------------- }}}
----------------------------------TELESCOPE--------------------------------- {{{
local function load_telescope()
    local has_telescope = pcall(require, 'telescope')
    local has_dap_telescope = pcall(cmd, 'packadd telescope-dap.nvim')

    if not has_telescope or not has_dap_telescope then
        do
            return
        end
    end

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
---------------------------------------------------------------------------- }}}
----------------------------------ON ATTACH--------------------------------- {{{
local function on_attach()
    local dap = require('dap')

    function _G.__dap_start()
        dap.continue()
        w.signcolumn = 'auto:2'
    end
    function _G.__dap_exit()
        dap.disconnect()
        w.signcolumn = 'auto'
    end

    load_telescope()

    local opts = {
        silent = true
    }
    utils.map_lua('n', '<Leader>b', 'require\'dap\'.toggle_breakpoint()', opts)
    utils.map_lua('n', '<F1>', '__dap_start()', opts)
    utils.map_lua('n', '<F2>', '__dap_exit()', opts)
    utils.map_lua('n', '<F3>', 'require\'dap\'.step_into()', opts)
    utils.map_lua('n', '<F4>', 'require\'dap\'.step_over()', opts)
    utils.map_lua('n', '<F5>', 'require\'dap\'.repl.open({}, \'vsplit\')', opts)
    utils.map_lua('n', '<F6>', '__telescope_breakpoints()', opts)
    utils.map_lua('n', '<Space>t', 'require\'dap-python\'.test_method()', opts)

    cmd 'command! -complete=file -nargs=* DebugPy lua require\'plugins.dap\'.attach_python_debugger({<f-args>})'
end
---------------------------------------------------------------------------- }}}
--------------------------------PYTHON LOCAL-------------------------------- {{{
M.attach_local_python_debugger = function()

    require('dap-python').setup('~/.asdf/shims/python3', {
        console = 'internalConsole'
    })
    require('dap-python').test_runner = 'pytest'

    require('dap').configurations.python = {{
        type = 'python',
        request = 'launch',
        name = "Launch file",
        program = "${file}",
        pythonPath = function()
            return 'python'
        end
    }}
end
---------------------------------------------------------------------------- }}}
--------------------------------PYTHON REMOTE------------------------------- {{{
M.attach_python_debugger = function(args)
    local dap = require "dap"
    local host = args[1] -- This should be configured for remote debugging if your SSH tunnel is setup.
    -- This should be configured for remote debugging if your SSH tunnel is setup.
    -- You can even make nvim responsible for starting the debugpy server/adapter:
    --  vim.fn.system({"${some_script_that_starts_debugpy_in_your_container}", ${script_args}})
    local port = tonumber(args[2])
    pythonAttachAdapter = {
        type = "server",
        host = host,
        port = port
    }
    pythonAttachConfig = {
        type = "python",
        request = "attach",
        connect = {
            host = host,
            port = port
        },
        mode = "remote",
        name = "Remote Attached Debugger",
        cwd = vim.fn.getcwd(),
        pathMappings = {{
            localRoot = fn.getcwd(), -- Wherever your Python code lives locally.
            remoteRoot = "/usr/src/app" -- Wherever your Python code lives in the container.
        }}
    }
    local session = dap.attach(host, port, pythonAttachConfig)
    if session == nil then
        io.write("Error launching adapter");
    end
    dap.repl.open({}, 'vsplit')
end
---------------------------------------------------------------------------- }}}
-----------------------------------CONFIG----------------------------------- {{{
function M.config()
    on_attach()
end
---------------------------------------------------------------------------- }}}
return M
