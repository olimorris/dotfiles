local ok, lsp = om.safe_require("lsp-zero")
local legendary_installed, legendary = om.safe_require("legendary", { silent = true })
if not ok or not legendary_installed then return end
-------------------------------------LSP------------------------------------ {{{
lsp.preset("lsp-compe")

lsp.set_preferences({
  set_lsp_keymaps = false,
  sign_icons = {
    error = " ",
    warn = " ",
    hint = " ",
    info = " ",
  },
})

lsp.ensure_installed({
  "bashls",
  "cssls",
  "dockerls",
  "html",
  "intelephense",
  "jsonls",
  "pyright",
  "solargraph",
  "sumneko_lua",
  "tailwindcss",
  "tsserver",
  "vuels",
  "yamlls",
})

lsp.nvim_workspace()

lsp.on_attach(function(client, bufnr)
  if legendary_installed then
    legendary.keymaps(require(config_namespace .. ".core.keymaps").lsp_keymaps(client, bufnr))
    legendary.autocmds(require(config_namespace .. ".core.autocmds").lsp_autocmds(client, bufnr))
    legendary.commands(require(config_namespace .. ".core.commands").lsp_commands(client, bufnr))
  end
end)

lsp.setup()

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
---------------------------------------------------------------------------- }}}
---------------------------------COMPLETION--------------------------------- {{{
vim.opt.completeopt = { "menu", "menuone", "noselect" }

local cmp = require("cmp")
local cmp_config = lsp.defaults.cmp_config({
  formatting = {
    format = function(...) return require("lspkind").cmp_format({ mode = "symbol_text" })(...) end,
  },
  sources = {
    -- path, buffer and luasnip are already setup
    { name = "nvim_lsp", keyword_length = 3, max_item_count = 5 },
    { name = "nvim_lua" },
    { name = "nvim_lsp_signature_help" },
  },
})

cmp.setup(cmp_config)

cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    {
      name = "cmdline",
      option = {
        ignore_cmds = { "Man", "!" },
      },
    },
  }),
})

cmp.setup.cmdline("/", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "buffer" },
  },
})

if legendary_installed then legendary.keymaps(require(config_namespace .. ".core.keymaps").completion_keymaps()) end
---------------------------------------------------------------------------- }}}
