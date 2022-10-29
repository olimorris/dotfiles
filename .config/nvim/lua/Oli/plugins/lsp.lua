------------------------------------SETUP----------------------------------- {{{
local ok, mason = om.safe_require("mason-lspconfig")
if not ok then return end
om.lsp = {}
--
-- The servers to automatically install using LSPI
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

-- Format on save, asynchronously and save the file
-- https://github.com/mrjones2014/dotfiles/blob/e6786500fc3b17d1d26a4e6ca93b33e5305798b1/.config/nvim/lua/lsp/init.lua#L4
vim.lsp.handlers["textDocument/formatting"] = function(err, result, client)
  if err ~= nil then
    vim.api.nvim_err_write(err)
    return
  end

  if result == nil then return end

  if
    vim.api.nvim_buf_get_var(client.bufnr, "format_changedtick")
    == vim.api.nvim_buf_get_var(client.bufnr, "changedtick")
  then
    local view = vim.fn.winsaveview()
    vim.lsp.util.apply_text_edits(result, client.bufnr, "utf-16")
    vim.fn.winrestview(view)
    if client.bufnr == vim.api.nvim_get_current_buf() then
      vim.b.format_saving = true
      vim.cmd("update")
      vim.b.format_saving = false
    end
  end
end
---------------------------------------------------------------------------- }}}
----------------------------------ON ATTACH--------------------------------- {{{
-- local symbols, aerial = om.safe_require("aerial", { silent = true })
local maps, legendary = om.safe_require("legendary", { silent = true })
local nav, navic = om.safe_require("nvim-navic", { silent = true })

if maps then
    legendary.bind_commands(require(config_namespace .. ".core.commands").lsp_basic_commands())
end

function om.lsp.on_attach(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  -- if symbols then
  --   pcall(aerial.on_attach, client, bufnr)
  -- end

  if maps then
    legendary.bind_keymaps(require(config_namespace .. ".core.mappings").lsp_keymaps(client, bufnr))
    legendary.bind_autocmds(require(config_namespace .. ".core.autocmds").lsp_autocmds(client, bufnr))
    legendary.bind_commands(require(config_namespace .. ".core.commands").lsp_commands(client, bufnr))
  end

  if nav and client.server_capabilities.documentSymbolProvider then pcall(navic.attach, client, bufnr) end
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
