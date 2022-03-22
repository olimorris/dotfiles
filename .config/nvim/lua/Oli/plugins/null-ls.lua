local ok, null_ls = om.safe_require("null-ls")
if not ok then
  return
end

local sources = {
  -- Code completion
  null_ls.builtins.code_actions.eslint_d,

  -- Diagnostics
  null_ls.builtins.diagnostics.jsonlint,

  -- Formatting
  null_ls.builtins.formatting.stylua,
  null_ls.builtins.formatting.fixjson,
  null_ls.builtins.formatting.rubocop,
  null_ls.builtins.formatting.shfmt.with({
    filetypes = { "sh", "zsh" },
  }),
  null_ls.builtins.formatting.prettier.with({
    filetypes = { "css", "dockerfile", "html", "javascript", "markdown", "vue", "yaml" },
  }),
}

null_ls.setup({
  sources = sources,
  on_attach = om.lsp.on_attach,
})
