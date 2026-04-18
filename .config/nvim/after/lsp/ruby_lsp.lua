---@type vim.lsp.Config
return {
  filetypes = { "ruby" },
  cmd = { "ruby-lsp" },
  root_markers = { "Gemfile", ".git" },
  init_options = {
    formatter = "standard",
    linters = { "standard" },
    addonSettings = {
      ["Ruby LSP Rails"] = {
        enablePendingMigrationsPrompt = false,
      },
    },
  },
}
