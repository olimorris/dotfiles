--------------------------------NEOVIM SERVER------------------------------- {{{
function LogNeovimAPIServer()
    -- On starting up, Neovim creates a server which is specefic to its
    -- instance. We write this instance into a text file so that external
    -- applications can pick this up and make API calls to.
    server_list = "/Users/Oli/.config/nvim/servers.txt"
    servers = io.open(server_list, "a")
    servers:write(vim.v.servername .. ',')
    servers:close(servers)
end
LogNeovimAPIServer()
function UnlogNeovimAPIServer()
    -- When we exit Neovim, we clear out the server name from the text file
    -- to ensure external apps are not querying a redundant server
    servers = io.open("/Users/Oli/.config/nvim/servers.txt", "r")
    data = servers:read()
    servers:close()

    servers = io.open("/Users/Oli/.config/nvim/servers.txt", "w+")
    new_data = string.gsub(data, vim.v.servername .. ',', '')
    servers:write(new_data)
    servers:close()
end
utils.create_augroup({{'VimLeave * call v:lua.UnlogNeovimAPIServer()'}}, 'neovim_api_server')
---------------------------------------------------------------------------- }}}
--------------------------------MINIMAL MODE-------------------------------- {{{
minimal_mode = 0
function ToggleMinimal()
    if minimal_mode == 0 then
        minimal_mode = 1
        w.number = false
        w.colorcolumn = '0'
        w.signcolumn = 'no'
        o.laststatus = 0
        o.showtabline = 0
        cmd 'ScrollViewDisable'
    else
        minimal_mode = 0
        w.number = true
        w.colorcolumn = '80'
        w.signcolumn = 'yes'
        o.laststatus = 2
        o.showtabline = 2
        cmd 'ScrollViewEnable'
    end
end
utils.map('n', '<S-m>', ':call v:lua.ToggleMinimal()<cr>', {
    silent = true
})
---------------------------------------------------------------------------- }}}
----------------------------------SNIPPETS---------------------------------- {{
function SnippetLookup()
    local snippet = fn.input('Snippets to edit: ')
    local path = os.getenv('HOME') .. '/.config/snippets'
    cmd(":edit " .. path .. "/" .. snippet .. ".json")
    print(" ")
end
utils.map('n', '<leader>es', ':call v:lua.SnippetLookup()<cr>', {
    silent = true
})
---------------------------------------------------------------------------- }}}
-------------------------------TERMINAL TOGGLE------------------------------ {{{
-- Uses the awesome kassio/neoterm plugin
function TermToggle(height)
    -- Always open the terminal in a horizontal pane at the bottom
    g.neoterm_default_mod = 'botright'
    -- Set the height of the terminal
    g.neoterm_size = height
    cmd ':Ttoggle'
end
-- utils.map('n', '<C-x>', ':call v:lua.TermToggle(8)<cr>', {silent = true})
-- utils.map('i', '<C-x>', '<esc>:call v:lua.TermToggle(8)<cr>', {silent = true})
-- utils.map('t', '<C-x>', '<C-\\><C-n>:call v:lua.TermToggle(8)<cr>', {silent = true})
---------------------------------------------------------------------------- }}}
------------------------------------THEME----------------------------------- {{{
function ThemeToggle()
    if vim.api.nvim_get_option('background') == 'dark' then
        vim.api.nvim_set_option('background', 'light')
    else
        vim.api.nvim_set_option('background', 'dark')
    end
end
utils.map('n', '<leader>1', ':call v:lua.ThemeToggle()<cr>', {
    silent = true
})

function SetTheme(color)
    vim.api.nvim_set_option('background', color)
end
---------------------------------------------------------------------------- }}}
