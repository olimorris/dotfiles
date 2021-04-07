local M = {}
local has_dap = pcall(cmd, 'packadd nvim-dap')
local has_dap_python = pcall(cmd, 'packadd nvim-dap-python')
local has_dap_vtext = pcall(cmd, 'packadd nvim-dap-virtual-text')

local debug_info = {}
g.debug_start = false
------------------------------------SETUP----------------------------------- {{{
function M.setup()
    if not has_dap then
        do
            return
        end
    end

    cmd 'packadd nvim-dap'

    if has_dap_python then
        cmd 'packadd nvim-dap-python'
    end
    if has_dap_vtext then
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
docker_attach_python_debugger = function(args)
    local host = args[1]
    local port = tonumber(args[2])

    local config = {
        type = "python",
        request = "attach",
        connect = {
            host = host,
            port = port
        },
        mode = "remote",
        name = "Remote Attached Debugger",
        cwd = fn.getcwd(),
        pathMappings = {{
            localRoot = fn.getcwd(), -- Wherever your Python code lives locally.
            remoteRoot = "/usr/src/app" -- Wherever your Python code lives in the container.
        }}
    }

    -- Attach to the connector
    local session = require('dap').attach(host, port, config)
    if session == nil then
        end_debugging()
        utils.echo_error('Error connecting to the debugger.')
    else
        utils.echo_success('Debugging on ' .. host .. ':' .. port .. ' with Job ID ' .. g.debug_job_id .. '.')
    end

    return true
end
---------------------------------------------------------------------------- }}}
------------------------------PYTHON DEBUGGING------------------------------ {{{
function debug_python_test(host, port)
    local debug_host = '0.0.0.0'
    local debug_port = 5678

    utils.echo_info('Waiting for debugger to attach...')

    if not g.debug_job_id then
        -- Get the name of the test which will trigger the debugging
        local test_method = fn['test#python#pytest#build_position']('nearest', {
            file = fn['expand']('%'),
            line = fn['line']('.'),
            col = fn['col']('.')
        })

        -- Pass the test name to pytest via debugpy
        local pytest_cmd =
            'docker-compose -f "./docker-compose.yml" exec -T -w /usr/src/app debug python -m debugpy --listen ' ..
                debug_host .. ':' .. debug_port .. ' --wait-for-client -m pytest ' .. test_method[1]

        -- Start the job and use the on_event callback to capture output
        g.debug_job_id = fn.jobstart(pytest_cmd, {
            on_stderr = on_event,
            on_stdout = on_event,
            on_exit = on_event,
            stdout_buffered = true,
            stderr_buffered = true
        })
        -- As we're using a Docker container, it's neccessary to wait for the
        -- cmd to be initiated before we attach the debugger
        utils.wait(2)
        load_python_debugger(debug_host, debug_port)
    else
        load_python_debugger(debug_host, debug_port)
    end
end

function load_python_debugger(host, port)
    docker_attach_python_debugger({host, port})
end

function on_event(job_id, data, event)
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

function end_debugging()
    if g.debug_job_id then
        fn.jobstop(g.debug_job_id)
    end
end
---------------------------------------------------------------------------- }}}
----------------------------------ON ATTACH--------------------------------- {{{
local function on_attach()

    load_telescope()

    local opts = {
        silent = true
    }
    utils.map_lua('n', '<Leader>d', 'debug_python_test()', opts)
    utils.map_lua('n', '<F1>', 'require\'dap\'.toggle_breakpoint()', opts)
    utils.map_lua('n', '<F2>', 'require\'dap\'.continue()', opts)
    utils.map_lua('n', '<F3>', 'require\'dap\'.step_into()', opts)
    utils.map_lua('n', '<F4>', 'require\'dap\'.step_over()', opts)
    utils.map_lua('n', '<F5>', 'require\'dap\'.repl.toggle({height = 6})', opts)
    utils.map_lua('n', '<F6>', 'end_debugging()', opts)
    utils.map_lua('n', '<F7>', '__telescope_breakpoints()', opts)
    utils.map_lua('n', '<F12>', 'require\'dap\'.run_last()', opts)

    cmd 'command! -complete=file -nargs=* DebugPy lua require\'plugins.dap\'.docker_attach_python_debugger({<f-args>})'
end
---------------------------------------------------------------------------- }}}
-----------------------------------CONFIG----------------------------------- {{{
function M.config()
    on_attach()
end
---------------------------------------------------------------------------- }}}
return M
