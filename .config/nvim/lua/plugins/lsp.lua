local M = {}
local has_lsp = pcall(cmd, "packadd nvim-lspconfig")
local has_lspsaga = pcall(cmd, "packadd lspsaga.nvim")
local has_lsptrouble = pcall(cmd, "packadd trouble.nvim")
local opts = {noremap = true, silent = true}
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

    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

    if client.resolved_capabilities.code_action then
        if pcall(cmd, 'packadd nvim-lightbulb') then
            cmd 'packadd nvim-lightbulb'
            utils.create_augroup({{"CursorHold,CursorHoldI * lua require('nvim-lightbulb').update_lightbulb()"}},
                'lsp_code_action')
        end
        buf_set_keymap("n", "ga", "<cmd>lua require('lspsaga.codeaction').code_action()<CR>", opts)
        buf_set_keymap("v", "ga", "<cmd>lua require('lspsaga.codeaction').range_code_action()<CR>", opts)
    end
    if client.resolved_capabilities.document_highlight then
        utils.create_augroup({{'CursorHold <buffer> lua vim.lsp.buf.document_highlight()'},
                            {'CursorMoved <buffer> lua vim.lsp.buf.clear_references()'}}, 'lsp_document_highlight')
    end

    -- Formatting is the sole responsibility of efm
    if client.name ~= 'efm' then client.resolved_capabilities.document_formatting = false end

    if client.resolved_capabilities.document_formatting then
        buf_set_keymap("n", "<space>=", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
        -- utils.create_augroup({{'BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)'}}, 'lsp_document_format')
    elseif client.resolved_capabilities.document_range_formatting then
        buf_set_keymap("v", "<space>=", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
    end

    if client.resolved_capabilities.goto_definition then
        buf_set_keymap("n", "gp", "<cmd>lua require('lspsaga.provider').preview_definition()<CR>", opts)
    end
    if client.resolved_capabilities.hover then
        buf_set_keymap("n", "K", "<cmd>lua require('lspsaga.hover').render_hover_doc()<CR>", opts)
    end
    if client.resolved_capabilities.find_references then
        buf_set_keymap("n", "gf", "<cmd>lua require('lspsaga.provider').lsp_finder()<CR>", opts)
    end
    if client.resolved_capabilities.rename then
        buf_set_keymap("n", "gr", "<cmd>lua require('lspsaga.rename').rename()<CR>", opts)
    end
    if client.resolved_capabilities.implementation then
        buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    end

    buf_set_keymap("n", "<space>d", "<cmd>lua require('lspsaga.diagnostic').show_line_diagnostics()<CR>", opts)

    -- utils.create_augroup({{"CursorHold * lua require('lspsaga.diagnostic').show_line_diagnostics()"},
    --                       {"CursorHoldI * silent! lua require('lspsaga.signaturehelp').signature_help()"}},
    --     'lsp_diagnostics')
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

    if has_lsptrouble then
        cmd 'packadd trouble.nvim'
        require('trouble').setup {
            auto_close = true
        }
        utils.map('n', 'L', '<cmd>LspTroubleToggle<CR>', opts)
    end

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
    -- lspconfig.gopls.setup {
    --     on_attach = function(client)
    --         client.resolved_capabilities.document_formatting = false
    --         on_attach(client)
    --     end
    -- }

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
    -- lspconfig.vimls.setup {
    --     on_attach = on_attach
    -- }

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
