------------------------------------INIT------------------------------------ {{{
local ok, mason = om.safe_require("mason-lspconfig")
if not ok then return end

om.lsp = {}

om.lsp.servers = {
  "bashls",
  "cssls",
  "dockerls",
  -- "efm",
  "html",
  "intelephense",
  "jsonls",
  "pyright",
  "solargraph",
  -- "sorbet",
  -- "ruby_ls",
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
  underline = false,
  update_in_insert = false,
  virtual_text = false,
  -- virtual_text = {
  --   prefix = "",
  --   spacing = 0,
  -- },
})
local max_width = math.max(math.floor(vim.o.columns * 0.7), 100)
local max_height = math.max(math.floor(vim.o.lines * 0.3), 30)

-- Sign column
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
---------------------------------------------------------------------------- }}}
----------------------------------HANDLERS---------------------------------- {{{
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
---------------------------------------------------------------------------- }}}
----------------------------------LSP SETUP--------------------------------- {{{
---Setup the plugins that require the LSP client
---@param client table
---@param bufnr number
local function setup_plugins(client, bufnr)
  local ok, navic = om.safe_require("nvim-navic", { silent = true })
  if ok and client.server_capabilities.documentSymbolProvider then pcall(navic.attach, client, bufnr) end
end

---Setup the mappings that require the LSP client
---@param client table
---@param bufnr number
local function setup_mappings(client, bufnr)
  -- Disable formatting with other LSPs because we're handling formatting via null-ls
  if client.name ~= 'null-ls' then
    client.server_capabilities.documentFormattingProvider = false
  end

  local ok, legendary = om.safe_require("legendary", { silent = true })
  if ok then
    legendary.keymaps(require(config_namespace .. ".core.mappings").lsp_keymaps(client, bufnr))
    -- legendary.bind_autocmds(require(config_namespace .. ".core.autocmds").lsp_autocmds(client, bufnr))
    legendary.commands(require(config_namespace .. ".core.commands").lsp_client_commands(client, bufnr))
  end
end

---Function to call when attaching to an LSP server
---@param client table
---@param bufnr number
function om.lsp.on_attach(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
  setup_plugins(client, bufnr)
  setup_mappings(client, bufnr)
end
---------------------------------------------------------------------------- }}}
--------------------------------SETUP SERVERS------------------------------- {{{
local capabilities = vim.lsp.protocol.make_client_capabilities()
local nvim_lsp_ok, cmp_nvim_lsp = om.safe_require("cmp_nvim_lsp")
if nvim_lsp_ok then capabilities = cmp_nvim_lsp.default_capabilities(capabilities) end

mason.setup({
  ensure_installed = om.lsp.servers,
  automatic_installation = true,
})

mason.setup_handlers({
  function(server_name)
    require("lspconfig")[server_name].setup({
      capabilities = capabilities,
      on_attach = om.lsp.on_attach,
    })
  end,
})

vim.cmd([[ do User LspAttachBuffers ]])
---------------------------------------------------------------------------- }}}
