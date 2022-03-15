local ok, lsp_installer = om.safe_require("nvim-lsp-installer")
if not ok then
  return
end
om.lsp = {}
-----------------------------------SERVERS---------------------------------- {{{
-- The servers to automatically install using LSPI
om.lsp.servers = {
  "bashls",
  "cssls",
  "dockerls",
  -- "efm",
  "html",
  "jsonls",
  "pyright",
  "solargraph",
  -- "sorbet",
  "sumneko_lua",
  "tailwindcss",
  "tsserver",
  "vuels",
  "yamlls",
}
---------------------------------------------------------------------------- }}}
-------------------------------------UI------------------------------------- {{{
vim.diagnostic.config({
  severity_sort = true,
  signs = true,
  underline = false, -- Do not underline code
  update_in_insert = false,
  virtual_text = false,
  -- virtual_text = {
  -- 	prefix = "",
  -- 	spacing = 0,
  -- },
})
local max_width = math.max(math.floor(vim.o.columns * 0.7), 100)
local max_height = math.max(math.floor(vim.o.lines * 0.3), 30)

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "single",
  max_width = max_width,
  max_height = max_height,
})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = "single",
  max_width = max_width,
  max_height = max_height,
})

-- Sign column
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
---------------------------------------------------------------------------- }}}
----------------------------------COMMANDS-----------------------------------{{{
om.command({
  "LspLog",
  function()
    vim.cmd("edit " .. vim.lsp.get_log_path())
  end,
})
om.command({
  "LspFormat",
  function()
    vim.lsp.buf.formatting_sync(nil, 1000)
  end,
})
om.command({
  "LspI",
  function()
    for _, name in pairs(om.lsp.servers) do
      vim.cmd("LspInstall " .. name)
    end
  end,
})
om.command({
  "LspUninstall",
  function()
    vim.cmd("LspUninstallAll")
  end,
})
---------------------------------------------------------------------------- }}}
-----------------------------------ATTACH----------------------------------- {{{
local symbols, aerial = om.safe_require("aerial", { silent = true })
local maps, legendary = om.safe_require("legendary", { silent = true })

function om.lsp.on_attach(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  if symbols then
    om.lsp.on_attach = pcall(aerial.on_attach, client, bufnr)
  end

  if maps then
    legendary.bind_keymaps(require(config_namespace .. ".core.mappings").lsp_keymaps(client, bufnr))
    legendary.bind_autocmds(require(config_namespace .. ".core.autocmds").lsp_autocmds(client))
  end
end
---------------------------------------------------------------------------- }}}
--------------------------------SETUP SERVERS------------------------------- {{{
local capabilities = vim.lsp.protocol.make_client_capabilities()

local ok, cmp_nvim_lsp = om.safe_require("cmp_nvim_lsp")
if ok then
  capabilities = cmp_nvim_lsp.update_capabilities(capabilities)
end

lsp_installer.settings({
  log_level = vim.log.levels.DEBUG,
  ui = {
    icons = {
      server_installed = "",
      server_pending = "",
      server_uninstalled = "",
    },
  },
})

-- Install LSP servers if they're not already installed
for _, name in pairs(om.lsp.servers) do
  local config_ok, server = lsp_installer.get_server(name)
  -- Check that the server is supported in nvim-lsp-installer
  if config_ok then
    if not server:is_installed() then
      vim.notify("Installing " .. name, nil)
      server:install()
    end
  end
end

lsp_installer.on_server_ready(function(server)
  local default_opts = { on_attach = om.lsp.on_attach, capabilities = capabilities }

  local server_opts = {
    -- ["efm"] = function()
    --     default_opts.cmd = {
    --         vim.fn.stdpath("data") .. "/lsp_servers/efm/efm-langserver",
    --         "-c",
    --         Homedir .. "/.config/efm-langserver/config.yaml"
    --     }
    --     default_opts.on_attach = on_attach
    --     default_opts.capabilities = capabilities
    --     default_opts.flags = { debounce_text_changes = 150 }
    --     default_opts.filetypes = {
    --         "css",
    --         "eruby",
    --         "html",
    --         "javascript",
    --         "json",
    --         "lua",
    --         "python",
    --         "scss",
    --         "sh",
    --         "yaml",
    --         "vue"
    --     }
    --     default_opts.init_options = { documentFormatting = true }
    --
    --     return default_opts
    -- end
  }

  server:setup(server_opts[server.name] and server_opts[server.name]() or default_opts)
  vim.cmd("do User LspAttachBuffers")
end)
---------------------------------------------------------------------------- }}}
