local M = {}
local has_lsp = pcall(cmd, "packadd nvim-lspconfig")
local has_lspsaga = pcall(cmd, "packadd lspsaga.nvim")
------------------------------------SETUP----------------------------------- {{{
function M.setup()
    if not has_lsp then
        do
            return
        end
    end

    cmd 'packadd nvim-lspconfig'

    local lsp, sign_define = vim.lsp, vim.fn.sign_define

    -- Define the diagnostic signs
    sign_define("LspDiagnosticsSignError", {
        text = "◉",
        texthl = "LspDiagnosticsDefaultError"
    })
    sign_define("LspDiagnosticsSignWarning", {
        text = "•",
        texthl = "LspDiagnosticsDefaultWarning"
    })
    sign_define("LspDiagnosticsSignInformation", {
        text = "•",
        texthl = "LspDiagnosticsDefaultInformation"
    })
    sign_define("LspDiagnosticsSignHint", {
        text = "⋄",
        texthl = "LspDiagnosticsDefaultHint"
    })

    -- See https://github.com/neovim/neovim/blob/master/runtime/doc/lsp.txt - *lsp-handler-configuration*
    -- How the diagnostic feedback in the editor is given
    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        signs = true,
        underline = true,
        virtual_text = false,
        update_in_insert = true
    })

    -- Handle formatting in a smarter way
    -- If the buffer has been edited before formatting has completed, do not try to
    -- apply the changes - by Lukas Reineke
    vim.lsp.handlers["textDocument/formatting"] = function(err, _, result, _, bufnr)
        if err ~= nil or result == nil then
            return
        end
        if not vim.api.nvim_buf_get_option(bufnr, "modified") then
            local view = vim.fn.winsaveview()
            vim.lsp.util.apply_text_edits(result, bufnr)
            vim.fn.winrestview(view)
            if bufnr == vim.api.nvim_get_current_buf() then
                vim.api.nvim_command("noautocmd :update")
            end
        end
    end

    vim.lsp.protocol.CompletionItemKind = {" [text]", " [method]", " [function]", " [constructor]",
                                           "ﰠ [field]", " [variable]", " [class]", " [interface]",
                                           " [module]", " [property]", " [unit]", " [value]", " [enum]",
                                           " [key]", "﬌ [snippet]", " [color]", " [file]", " [reference]",
                                           " [folder]", " [enum member]", " [constant]", " [struct]",
                                           "⌘ [event]", " [operator]", "♛ [type]"}
end
---------------------------------------------------------------------------- }}}
-----------------------------------ATTACH----------------------------------- {{{
local function on_attach(client, bufnr)
    require('lspsaga').init_lsp_saga({
        use_saga_diagnostic_sign = false,
        code_action_prompt = {
            enable = false,
            sign = false,
            sign_priority = 20,
            virtual_text = false
        },
        code_action_keys = {
            quit = "<ESC>",
            exec = "<CR>"
        }
    })

    local opts = {
        silent = true
    }

    if client.resolved_capabilities.code_action then
        if pcall(cmd, 'packadd nvim-lightbulb') then
            cmd 'packadd nvim-lightbulb'
            utils.create_augroup({{"CursorHold,CursorHoldI * lua require('nvim-lightbulb').update_lightbulb()"}},
                'lsp_code_action')
        end
        utils.map_lua("n", "ga", "require('lspsaga.codeaction').code_action()", opts)
        utils.map_lua("v", "ga", "require('lspsaga.codeaction').range_code_action()", opts)
    end
    if client.resolved_capabilities.document_highlight then
        utils.create_augroup({{'CursorHold <buffer> lua vim.lsp.buf.document_highlight()'},
                              {'CursorMoved <buffer> lua vim.lsp.buf.clear_references()'}}, 'lsp_document_highlight')
    end
    if client.resolved_capabilities.document_formatting then
        -- Format a document on save
        -- This can be toggled using FormatDisable/FormatEnable
        utils.create_augroup({{'BufWritePost <buffer> lua formatting()'}}, 'lsp_document_format')
        utils.map_lua("n", "F", "formatting()", opts)
    end
    if client.resolved_capabilities.goto_definition then
        utils.map_lua("n", "gp", "require('lspsaga.provider').preview_definition()", opts)
    end
    if client.resolved_capabilities.hover then
        utils.map_lua("n", "K", "require('lspsaga.hover').render_hover_doc()", opts)
    end
    if client.resolved_capabilities.find_references then
        utils.map_lua("n", "gf", "require('lspsaga.provider').lsp_finder()", opts)
    end
    if client.resolved_capabilities.rename then
        utils.map_lua("n", "gr", "require('lspsaga.rename').rename()", opts)
    end
    if client.resolved_capabilities.implementation then
        utils.map("n", "gD", "vim.lsp.buf.implementation()", opts)
    end

    utils.map_lua("n", "<Space>", "require('lspsaga.diagnostic').show_line_diagnostics()", opts)

    utils.create_augroup({{"CursorHold * lua require('lspsaga.diagnostic').show_line_diagnostics()"},
                          {"CursorHoldI * silent! lua require('lspsaga.signaturehelp').signature_help()"}},
        'lsp_diagnostics')
end
---------------------------------------------------------------------------- }}}
--------------------------------SERVER SETUP-------------------------------- {{{
function M.config()
    if not has_lsp then
        print("LSP has not been installed.")
        do
            return
        end
    end

    if not has_lspsaga then
        print("LSP Saga has not been installed.")
        do
            return
        end
    end

    cmd 'packadd lspsaga.nvim'

    local lspconfig = require('lspconfig')
    vim.lsp.set_log_level('info')

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
---------------------------------LSP SERVERS-------------------------------- {{{
    local util = require('lspconfig/util')

    -- https://github.com/theia-ide/typescript-language-server
    lspconfig.tsserver.setup {
        root_dir = util.root_pattern("yarn.lock", "package.json", ".git/"),
        on_attach = function(client)
            client.resolved_capabilities.document_formatting = false
            on_attach(client)
        end
    }

    -- https://github.com/microsoft/pyright
    lspconfig.pyright.setup {
        on_attach = on_attach
    }

    -- https://github.com/golang/tools/tree/master/gopls
    lspconfig.gopls.setup {
        on_attach = function(client)
            client.resolved_capabilities.document_formatting = false
            on_attach(client)
        end
    }

    lspconfig.sumneko_lua.setup {
        cmd = {
            os.getenv('HOME') .. '/.local/lua-language-server/bin/macOS/lua-language-server',
            '-E',
            os.getenv('HOME') .. '/.local/lua-language-server/main.lua'
        },
        on_attach = on_attach,
        root_dir = function(fname)
            return util.find_git_ancestor(fname) or util.path.dirname(fname)
        end,
        settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT"
                },
                diagnostics = {
                    enable = true,
                    globals = {'vim'}
                },
                workspace = {
                    -- Make the server aware of Neovim runtime files
                    library = {
                        [fn.expand('$VIMRUNTIME/lua')] = true,
                        [fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true
                    }
                }
            }
        }
    }

    -- https://github.com/iamcco/vim-language-server
    lspconfig.vimls.setup {
        on_attach = on_attach
    }

    -- https://github.com/vscode-langservers/vscode-json-languageserver
    lspconfig.jsonls.setup {
        on_attach = on_attach
    }

    -- https://github.com/redhat-developer/yaml-language-server
    lspconfig.yamlls.setup {
        on_attach = on_attach
    }

    -- https://github.com/vscode-langservers/vscode-css-languageserver-bin
    lspconfig.cssls.setup {
        on_attach = on_attach
    }

    -- https://github.com/vscode-langservers/vscode-html-languageserver-bin
    lspconfig.html.setup {
        on_attach = function(client)
            client.resolved_capabilities.document_formatting = false
            on_attach(client)
        end
    }

    -- https://github.com/bash-lsp/bash-language-server
    lspconfig.bashls.setup {
        on_attach = on_attach
    }

    -- https://github.com/rcjsuen/dockerfile-language-server-nodejs
    lspconfig.dockerls.setup {
        on_attach = on_attach
    }

    -- https://github.com/vuejs/vetur/tree/master/server
    lspconfig.vuels.setup {
        on_attach = on_attach
    }
-------------------------------------EFM------------------------------------ {{{
    -- NOTE:
    -- The formatting options are in the efm-langserver/config.yaml file

    -- Specify default options for prettier
    local format_options_prettier = {
        tabWidth = 4,
        singleQuote = true,
        trailingComma = "all",
        configPrecedence = "prefer-file"
    }
    g.format_options_typescript = format_options_prettier
    g.format_options_javascript = format_options_prettier
    g.format_options_typescriptreact = format_options_prettier
    g.format_options_javascriptreact = format_options_prettier
    g.format_options_json = format_options_prettier
    g.format_options_css = format_options_prettier
    g.format_options_scss = format_options_prettier
    g.format_options_html = format_options_prettier
    g.format_options_yaml = format_options_prettier
    g.format_options_markdown = format_options_prettier
    g.format_options_vue = format_options_prettier

    FormatToggle = function(value)
        g[string.format("format_disabled_%s", b.filetype)] = value
    end
    cmd 'command! FormatDisable lua FormatToggle(true)'
    cmd 'command! FormatEnable lua FormatToggle(false)'

    -- We use a custom formatting function to pass our default prettier options
    -- to the default Lsp formatter, otherwise format as normal
    _G.formatting = function()
        if not g[string.format("format_disabled_%s", b.filetype)] then
            vim.lsp.buf.formatting(g[string.format("format_options_%s", b.filetype)] or {})
        end
    end

    -- https://github.com/mattn/efm-langserver
    lspconfig.efm.setup {
        cmd = {'efm-langserver', '-c', os.getenv('HOME') .. '/.config/efm-langserver/config.yaml'},
        on_attach = on_attach,
        filetypes = {'python', 'javascript', 'html', 'css', 'json', 'lua', 'vue', 'scss'},
        init_options = {
            documentFormatting = true
        }
    }
---------------------------------------------------------------------------- }}}
---------------------------------------------------------------------------- }}}
end
---------------------------------------------------------------------------- }}}
return M
