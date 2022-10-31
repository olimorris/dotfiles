local ok, null_ls = om.safe_require("null-ls")
if not ok then return end

local ok, mason_null_ls = om.safe_require("mason-null-ls")
if not ok then return end

mason_null_ls.setup({
  ensure_installed = {
    "eslint_d",
    "fish_indent",
    "fixjson",
    "phpcsfixer",
    "prettier",
    "rubocop",
    "shfmt",
    "stylua",
  },
  automatic_installation = true,
})

null_ls.setup({
  debounce = 150,
  sources = {
    -- Code completion
    null_ls.builtins.code_actions.eslint_d,

    -- Formatting
    null_ls.builtins.formatting.fish_indent,
    null_ls.builtins.formatting.fixjson,
    null_ls.builtins.formatting.phpcsfixer,
    null_ls.builtins.formatting.prettier.with({
      filetypes = {
        "css",
        "dockerfile",
        "html",
        "javascript",
        "json",
        "markdown",
        "vue",
        "yaml",
      },
    }),
    null_ls.builtins.formatting.rubocop,
    null_ls.builtins.formatting.shfmt.with({
      filetypes = { "sh", "zsh" },
    }),
  null_ls.builtins.formatting.stylua,
  },
  on_attach = om.lsp.on_attach, -- Use the same on_attach function as the LSP client
  update_on_insert = true,
})
