---@type vim.lsp.Config
return {
  cmd = {
    "copilot-language-server",
    "--stdio",
  },
  root_markers = { ".git", "README.md" },
  init_options = {
    editorInfo = {
      name = "Neovim",
      version = tostring(vim.version()),
    },
    editorPluginInfo = {
      name = "Neovim",
      version = tostring(vim.version()),
    },
  },
  settings = {
    telemetry = {
      telemetryLevel = "off",
    },
  },
}
