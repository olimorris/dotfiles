o = vim.o -- vim options

g = vim.g -- vim global variables

w = vim.wo -- vim window options

b = vim.bo -- vim buffer options

fn = vim.fn -- to call Vim functions e.g. fn.bufnr()

cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')

exec = vim.api.nvim_command

local M = {} -- The module to export

-- We will create a few autogroup, this function will help to avoid
-- always writing cmd('augroup' .. group) etc..
function M.create_augroup(autocmds, name)
    cmd('augroup ' .. name)
    cmd('autocmd!')
    for _, autocmd in ipairs(autocmds) do
        cmd('autocmd ' .. table.concat(autocmd, ' '))
    end
    cmd('augroup END')
end

function M.create_higroup(highlights)
    for _, highlight in ipairs(highlights) do
        cmd('hi ' .. table.concat(highlight, ' '))
    end
end

-- Print a tables values
function M.print_table(t)
    require'pl.pretty'.dump(t)
end

-- Merge two tables together
function M.merge_tables(a, b)
    if type(a) == 'table' and type(b) == 'table' then
        for k, v in pairs(b) do
            if type(v) == 'table' and type(a[k] or false) == 'table' then
                merge(a[k], v)
            else
                a[k] = v
            end
        end
    end
    return a
end

-- Map a key with optional options
function M.map(mode, keys, action, options)
    options = M.merge_tables({
        noremap = true
    }, options)
    vim.api.nvim_set_keymap(mode, keys, action, options)
end

-- Map a key to a lua callback
function M.map_lua(mode, keys, action, options)
    options = M.merge_tables({
        noremap = true
    }, options)
    vim.api.nvim_set_keymap(mode, keys, "<cmd>lua " .. action .. "<CR>", options)
end
function M.vmap_lua(keys, action, options)
    options = M.merge_tables({
        noremap = true
    }, options)
    vim.api.nvim_set_keymap("v", keys, "<cmd>'<,'>lua " .. action .. "<CR>", options)
end

-- Buffer local mappings
function M.map_buf(mode, keys, action, options, buf_nr)
    options = M.merge_tables({
        noremap = true
    }, options)
    local buf = buf_nr or 0
    vim.api.nvim_buf_set_keymap(buf, mode, keys, action, options)
end

function M.map_lua_buf(mode, keys, action, options, buf_nr)
    options = M.merge_tables({
        noremap = true
    }, options)
    local buf = buf_nr or 0
    vim.api.nvim_buf_set_keymap(buf, mode, keys, "<cmd>lua " .. action .. "<CR>", options)
end

function M.has_key(table, key)
    return table.key ~= nil
end

-- Others
function M.wait(seconds)
    local start = os.time()
    repeat
    until os.time() > start + seconds
end
function M.echo_success(message)
    cmd("silent! echohl MoreMsg | echo '" .. message .. "' | echohl None")
    cmd('redraw!')
end
function M.echo_error(message)
    cmd("silent! echohl Error | echo '" .. message .. "' | echohl None")
    cmd('redraw!')
end
function M.echo_info(message)
    cmd("silent! echohl ModeMsg | echo '" .. message .. "' | echohl None")
    cmd('redraw!')
end

-- We want to be able to access utils in all our configuration files
-- so we add the module to the _G global variable.
_G.utils = M
return M -- Export the module
