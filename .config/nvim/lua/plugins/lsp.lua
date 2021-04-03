local M = {}
local has_lsp = pcall(require, "lspconfig")
local has_lspkind = pcall(require, "lspkind")
local has_lspsaga = pcall(require, "lspsaga")
local has_lspinstall = pcall(require, "lspinstall")
------------------------------------SETUP----------------------------------- {{{
function M.setup()

    if not has_lsp then
        do
            return
        end
    end

    local lsp, sign_define = vim.lsp, vim.fn.sign_define

    -- Define the signs
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
    -- apply the changes, by Lukas Reineke
    vim.lsp.handlers['textDocument/formatting'] = function(err, _, result, _, bufnr)
        if err ~= nil or result == nil then
            return
        end

        -- If the buffer hasn't been modified before the formatting has finished,
        -- update the buffer
        if not vim.api.nvim_buf_get_option(bufnr, 'modified') then
            local view = vim.fn.winsaveview()
            vim.lsp.util.apply_text_edits(result, bufnr)
            vim.fn.winrestview(view)
            if bufnr == vim.api.nvim_get_current_buf() then
                vim.api.nvim_command('noautocmd :update')

                -- Trigger post-formatting autocommand which can be used to refresh gitgutter
                vim.api.nvim_command('silent doautocmd <nomodeline> User FormatterPost')
            end
        end
    end
end
---------------------------------------------------------------------------- }}}
------------------------------CUSTOM FUNCTIONS------------------------------ {{{
function lsp_format_before_save()
    local defs = {}
    local ext = fn.expand('%:e')
    table.insert(defs, {"BufWritePre", '*.' .. ext, "lua vim.lsp.buf.formatting_sync(nil,1000)"})
    utils.create_augroup(defs, 'lsp_format_before_save')
end

function _G.reload_lsp()
    vim.lsp.stop_client(vim.lsp.get_active_clients())
    cmd [[edit]]
end
function _G.open_lsp_log()
    local path = vim.lsp.get_log_path()
    cmd("edit " .. path)
end
cmd('command! -nargs=0 LspLog call v:lua.open_lsp_log()')
cmd('command! -nargs=0 LspRestart call v:lua.reload_lsp()')
---------------------------------------------------------------------------- }}}
-----------------------------------CONFIG----------------------------------- {{{
-----------------------------------ATTACH----------------------------------- {{{
local function on_attach(client, bufnr)
    -- Omni completion in insert mode
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    if client.resolved_capabilities.document_highlight then
        utils.create_augroup({{'CursorHold <buffer> lua vim.lsp.buf.document_highlight()'},
                              {'CursorMoved <buffer> lua vim.lsp.buf.clear_references()'}}, 'lsp_document_highlight')
    end

    if client.resolved_capabilities.document_formatting then
        -- lsp_format_before_save()
        utils.map("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", {
            silent = true
        })
    elseif client.resolved_capabilities.document_range_formatting then
        utils.map("n", "<space>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", {
            silent = true
        })
    end

    if client.resolved_capabilities.implementation then
        utils.map("n", "gD", "vim.lsp.buf.implementation()")
    end

    if client.resolved_capabilities.code_action then
        cmd [[packadd nvim-lightbulb]]
        cmd [[autocmd CursorHold * lua require('nvim-lightbulb').update_lightbulb()]]
    end
end
---------------------------------------------------------------------------- }}}
--------------------------------SERVER SETUP-------------------------------- {{{
local function make_config()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    return {
        -- enable snippet support
        capabilities = capabilities,
        -- map buffer local keybindings when the language server attaches
        on_attach = on_attach
    }
end
function M.setup_servers()
    require('lspinstall').setup()

    -- get all installed servers
    local servers = require('lspinstall').installed_servers()

    for _, server in pairs(servers) do
        local config = make_config()

        -- language specific config
        if server == "efm" then
            config = vim.tbl_extend("force", config, require('plugins.lsp_custom').efm_settings)
        end
        if server == "lua" then
            config.settings = require('plugins.lsp_custom').lua_settings
        end

        require('lspconfig')[server].setup(config)
    end
end
---------------------------------------------------------------------------- }}}
function M.config()
    if not has_lsp then
        print("Failed to attach LSP.")
        do
            return
        end
    end

    -- Enable icons in the completion menu
    if has_lspkind then
        require('lspkind').init()
    end
    
    -- Enable the cool hover menus but don't show the icons
    if has_lspsaga then
        require('lspsaga').init_lsp_saga({
            use_saga_diagnostic_sign = false,
            code_action_prompt = {
                enable = false,
                sign = false,
                sign_priority = 20,
                virtual_text = false
            }
        })

        cmd [[autocmd CursorHold * lua require('lspsaga.diagnostic').show_line_diagnostics()]]
        cmd [[autocmd CursorHoldI * silent! lua require('lspsaga.signaturehelp').signature_help()]]

        utils.map_lua("n", "ga", "require('lspsaga.codeaction').code_action()")
        utils.vmap_lua("ga", "require('lspsaga.codeaction').range_code_action()")
        utils.map_lua("n", "gf", "require('lspsaga.provider').lsp_finder()")
        utils.map_lua("n", "gs", "require('lspsaga.signaturehelp').signature_help()")
        utils.map_lua("n", "gr", "require('lspsaga.rename').rename()")

        -- Hover and definitions with scroll ability
        utils.map_lua("n", "K", "require('lspsaga.hover').render_hover_doc()")
        utils.map_lua("n", "gp", "require('lspsaga.provider').preview_definition()")

        -- diagnostic
        utils.map_lua("n", "gd", "require('lspsaga.diagnostic').show_line_diagnostics()")
        utils.map_lua("n", "g[", "require('lspsaga.diagnostic').lsp_jump_diagnostic_prev()")
        utils.map_lua("n", "g]", "require('lspsaga.diagnostic').lsp_jump_diagnostic_next()")
    end

    return M.setup_servers()
end
---------------------------------------------------------------------------- }}}
------------------------------------HOOKS----------------------------------- {{{
if has_lspinstall then
    -- Automatically reload after `:LspInstall <server>` so we don't have to restart neovim
    require('lspinstall').post_install_hook = function()
        M.setup_servers() -- reload installed servers
        cmd("bufdo e") -- this triggers the FileType autocmd that starts the server
    end
    require('lspinstall').post_uninstall_hook = function()
        M.setup_servers() -- reload installed servers
        cmd("bufdo e") -- this triggers the FileType autocmd that starts the server
    end
end
---------------------------------------------------------------------------- }}}
return M
