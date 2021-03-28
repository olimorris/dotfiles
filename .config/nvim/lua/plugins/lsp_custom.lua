local M = {}
-------------------------------------EFM------------------------------------ {{{
local eslint = {
    lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
    lintStdin = true,
    lintFormats = {"%f:%l:%c: %m"},
    lintIgnoreExitCode = true,
    formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
    formatStdin = true
}
local prettier = {
    formatCommand = "prettier --stdin-filepath ${INPUT}",
    formatStdin = true
}
local black = {formatCommand = "black --quiet -", formatStdin = true}
local luaformat = {formatCommand = "lua-format -i", formatStdin = true}
local isort = {
    formatCommand = "isort --quiet -",
    formatStdin = true
}
local mypy = {
    lintCommand = "mypy --show-column-numbers",
    lintFormats = {
        '%f:%l:%c: %trror: %m', '%f:%l:%c: %tarning: %m', '%f:%l:%c: %tote: %m'
    }
}
local languages = {
    python = {isort, black},
    lua = {luaformat},
    vue = {prettier, eslint},
    typescript = {prettier, eslint},
    javascript = {prettier, eslint},
    typescriptreact = {prettier, eslint},
    javascriptreact = {prettier, eslint},
    yaml = {prettier},
    json = {prettier},
    html = {prettier},
    scss = {prettier},
    css = {prettier},
    markdown = {prettier}
}
M.efm_settings = {
    filetypes = vim.tbl_keys(languages),
    init_options = {documentFormatting = true},
    settings = {
        -- Root markers are in the main efm-langserver/config.yaml file
        languages = languages
    }
}
---------------------------------------------------------------------------- }}}
-------------------------------------LUA------------------------------------ {{{
M.lua_settings = {
    Lua = {
        runtime = {
            -- LuaJIT in the case of Neovim
            version = 'LuaJIT',
            path = vim.split(package.path, ';')
        },
        diagnostics = {
            -- Get the language server to recognize the `vim` global
            globals = {'vim'}
        },
        workspace = {
            -- Make the server aware of Neovim runtime files
            library = {
                [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true
            }
        }
    }
}
---------------------------------------------------------------------------- }}}
return M
