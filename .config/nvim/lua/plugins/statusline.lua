if not pcall(cmd, 'packadd galaxyline.nvim') then
    do return end
end

cmd 'packadd galaxyline.nvim'

local gl = require('galaxyline')
local gls = gl.section
local condition = require('galaxyline.condition')
local vcs = require('galaxyline.provider_vcs')

-- Don't show the statusline in these windows
gl.short_line_list = {'packer', 'NvimTree', 'floaterm', 'dap-repl'}

-----------------------------------COLORS----------------------------------- {{{
local dark = {
    bg = '#1e1e1e',
    fg = '#aab2bf',
    error = '#FC5C94',

    red = '#e06c75',
    green = '#98c379',
    yellow = '#e5c07b',
    blue = '#61afef',
    purple = '#c678dd',
    gray = '#4c4f55',

    -- mode colors
    normal = '#98c379', -- green
    insert = '#61afef', -- blue
    command = '#e5c07b', -- yellow
    visual = '#c678dd', -- purple
    replace = '#e06c75' -- red
}
local light = {
    bg = '#fafafa',
    fg = '#6a6a6a',
    error = '#FC5C94',

    red = '#e05661',
    green = '#1da912',
    yellow = '#eea825',
    blue = '#118dc3',
    purple = '#9a77cf',
    gray = '#bebebe',

    -- mode colors
    normal = '#1da912', -- green
    insert = '#118dc3', -- blue
    command = '#eea825', -- yellow
    visual = '#9a77cf', -- purple
    replace = '#e05661' -- red
}
local settings = {bold = 1, italic = 1, bold_italic = 1}
---------------------------------------------------------------------------- }}}
------------------------------CUSTOM FUNCTIONS------------------------------ {{{
-- Return a closure function of the hex color
function color(val)
    return function()
        if vim.o.background ~= nil and vim.o.background == "light" then
            return light[val]
        else
            return dark[val]
        end
    end
end
-- Used to get a hex color
function get_color(val)
    if vim.o.background ~= nil and vim.o.background == "light" then
        return light[val]
    else
        return dark[val]
    end
end

-- Get LSP providers
function get_lsp()
    return function()
        local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
        local clients = vim.lsp.get_active_clients()
        if next(clients) == nil then return ' [None]' end
        local lsps = ' ['
        local n = 0
        for _, client in ipairs(clients) do
            local filetypes = client.config.filetypes
            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                if n == 0 then
                    lsps = lsps .. client.name
                    n = n + 1
                else
                    -- Ensure we don't duplicate Lsps in the statusline
                    if not string.find(lsps, client.name) then
                        lsps = lsps .. ' ' .. client.name
                    end
                    n = n + 1
                end
            end
        end
        return lsps .. ']'
    end
end
---------------------------------------------------------------------------- }}}
------------------------------CUSTOM CONDITIONS----------------------------- {{{
function changes_to_diff()
    return (vcs.diff_add() ~= nil or vcs.diff_modified() ~= nil or
               vcs.diff_remove() ~= nil)
end
function has_lsp() return get_lsp() ~= nil end
function has_git() return vcs.get_git_branch() ~= nil end
function using_session() return (fn.ObsessionStatus() ~= nil) end
---------------------------------------------------------------------------- }}}
---------------------------------STATUSLINE--------------------------------- {{{
------------------------------------LEFT------------------------------------ {{{
gls.left = {
    {
        ViMode = {
            provider = function()
                -- local alias = {n = 'NORMAL',i = 'INSERT',c = 'COMMAND',V = 'VISUAL', [''] = 'VISUAL'}
                local mode_color = {
                    n = get_color('normal'),
                    i = get_color('insert'),
                    c = get_color('command'),
                    V = get_color('visual'),
                    [' '] = get_color('visual')
                }
                mode = vim.fn.mode()
                if mode_color[mode] ~= nil then
                    vim.api.nvim_command('hi GalaxyViMode guibg=' ..mode_color[mode])
                    vim.api.nvim_command('hi GalaxyViModeInv guifg=' ..mode_color[mode])
                end
                return '    '
            end,
            highlight = {
                color('bg'), color('bg'),
                function()
                    if settings.bold == 1 then return 'BOLD' end
                end
            }
        }
    }, {
        Space = {
            provider = function() return ' ' end,
            condition = condition.buffer_not_empty,
            separator = ' ',
            highlight = {color('bg'), color('bg')}
        }
    }, {
        DiagnosticError = {
            provider = 'DiagnosticError',
            icon = ' ',
            highlight = {color('gray'), color('bg')}
        }
    }, {
        DiagnosticWarn = {
            provider = 'DiagnosticWarn',
            icon = ' ',
            highlight = {color('gray'), color('bg')}
        }
    }, {
        DiagnosticInfo = {
            provider = 'DiagnosticInfo',
            icon = ' ',
            highlight = {color('gray'), color('bg')},
            separator_highlight = {color('gray'), color('bg')}
        }
    }, {
        ShowLspClient = {
            provider = get_lsp(),
            condition = condition.buffer_not_empty,
            icon = '  Lsp:',
            highlight = {color('gray'), color('bg')}
        }
    }
}
---------------------------------------------------------------------------- }}}
------------------------------------RIGHT----------------------------------- {{{
gls.right = {
    {
        Session = {
            provider = function()
                return fn.ObsessionStatus(' ', ' ')
            end,
            condition = condition.buffer_not_empty,
            highlight = {color('gray'), color('bg')}
        }
    }, {
        Separator = {
            provider = function()
                if using_session() and (changes_to_diff() or has_git()) then
                    return '| '
                end
            end,
            separator = ' ',
            condition = condition.buffer_not_empty,
            highlight = {color('gray'), color('bg')}
        }
    }, {
        DiffAdd = {
            provider = 'DiffAdd',
            icon = '+',
            highlight = {color('gray'), color('bg')}
        }
    }, {
        DiffModified = {
            provider = 'DiffModified',
            icon = '~',
            highlight = {color('gray'), color('bg')}
        }
    }, {
        DiffRemove = {
            provider = 'DiffRemove',
            icon = '-',
            highlight = {color('gray'), color('bg')}
        }
    }, {
        Space = {
            provider = function()
                if changes_to_diff() then return '  ' end
            end,
            condition = condition.buffer_not_empty,
            highlight = {color('gray'), color('bg')}
        }
    }, {
        GitIcon = {
            provider = function() return ' ' end,
            condition = condition.check_git_workspace,
            highlight = {color('gray'), color('bg')}
        }
    }, {
        GitBranch = {
            provider = 'GitBranch',
            condition = condition.check_git_workspace,
            highlight = {color('gray'), color('bg')}
        }
    }
}
---------------------------------------------------------------------------- }}}
---------------------------------------------------------------------------- }}}
-- Force manual load so that nvim boots with a status line
gl.load_galaxyline()
