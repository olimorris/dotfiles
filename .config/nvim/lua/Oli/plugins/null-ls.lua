local ok, null_ls = om.safe_require("null-ls")
if not ok then
  return
end

local b = null_ls.builtins

local sources = {
  -- Code completion
  b.code_actions.eslint_d,

  -- Diagnostics
  b.diagnostics.eslint_d,
  b.diagnostics.jsonlint,

  -- Formatting
  b.formatting.fish_indent,
  b.formatting.fixjson,
  b.formatting.phpcsfixer,
  b.formatting.prettier.with({
    filetypes = { "css", "dockerfile", "html", "javascript", "markdown", "vue", "yaml" },
  }),
  b.formatting.rubocop,
  b.formatting.shfmt.with({
    filetypes = { "sh", "zsh" },
  }),
  b.formatting.stylua,
}

null_ls.setup({
  sources = sources,
  on_attach = om.lsp.on_attach,
  update_on_insert = true,
})
