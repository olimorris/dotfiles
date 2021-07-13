local M = {}
local has_plugin = pcall(cmd, 'packadd nvim-compe')

function M.config()
------------------------------------COMPE----------------------------------- {{{
    if not has_plugin then
        do return end
    end

    cmd 'packadd nvim-compe'

    require('compe').setup {
        enabled = true,
        autocomplete = true,
        debug = false,
        min_length = 1,
        preselect = 'disable',
        allow_prefix_unmatch = false,
        source = {
            vsnip = true,
            path = true,
            buffer = true,
            nvim_lsp = true,
            nvim_lua = true,
        },
        -- Aesthetics
        max_abbr_width = 100,
        max_kind_width = 100,
        max_menu_width = 100,
        documentation = {
            border = "rounded",
            max_width = 120,
            max_height = math.floor(vim.o.lines * 0.3),
            min_height = 1
        }
    }

    -- Maximum number of completion-menu items
    vim.o.pumheight = 10
---------------------------------------------------------------------------- }}}
----------------------------------SNIPPETS---------------------------------- {{{
    g.vsnip_snippet_dir = os.getenv('HOME') .. '/.dotfiles/.config/snippets'
    
    local t = function(str)
        return vim.api.nvim_replace_termcodes(str, true, true, true)
    end
    
    local check_back_space = function()
        local col = vim.fn.col('.') - 1
        if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
            return true
        else
            return false
        end
    end
    
    -- Use (s-)tab to:
    --- move to prev/next item in completion menuone
    --- jump to prev/next snippet's placeholder
    _G.tab_complete = function()
        if vim.fn.pumvisible() == 1 then
            return t "<C-n>"
        elseif vim.fn.call("vsnip#available", {1}) == 1 then
            return t "<Plug>(vsnip-expand-or-jump)"
        elseif check_back_space() then
            return t "<Tab>"
        else
            return vim.fn['compe#complete']()
        end
    end
    _G.s_tab_complete = function()
        if vim.fn.pumvisible() == 1 then
            return t "<C-p>"
        elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
            return t "<Plug>(vsnip-jump-prev)"
        else
            return t "<S-Tab>"
        end
    end
    
    vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
    vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
    vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
    vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
    vim.api.nvim_set_keymap('i', '<CR>', [[compe#confirm('<CR>')]], {expr = true})
---------------------------------------------------------------------------- }}}
end

return M
