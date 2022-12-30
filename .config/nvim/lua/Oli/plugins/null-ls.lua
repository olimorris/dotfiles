local M = {
  "jose-elias-alvarez/null-ls.nvim", -- General purpose LSP server for running linters, formatters, etc
  dependencies = {
    {
      "jayp0521/mason-null-ls.nvim", -- Automatically install null-ls servers
      commit = "ab5d99619de2263508abb7fb05ef3a0f24a8d73d",
    },
    "williamboman/mason.nvim",
  },
}

function M.config()
  require("mason-null-ls").setup({
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
    automatic_setup = false,
  })

  local null_ls = require("null-ls")
  null_ls.setup({
    debounce = 150,
    sources = {
      -- Code completion
      null_ls.builtins.code_actions.eslint_d,

      -- Formatting
      null_ls.builtins.formatting.fish_indent,
      null_ls.builtins.formatting.fixjson,
      null_ls.builtins.formatting.google_java_format,
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
  })
end

return M
