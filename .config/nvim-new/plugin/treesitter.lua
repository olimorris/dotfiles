local treesitter = require("nvim-treesitter")

-- Some default parsers that I always want installed
local ensure_installed = {
  "css",
  "diff",
  "gitcommit",
  "gitignore",
  "html",
  "javascript",
  "latex",
  "ledger",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "regex",
  "ruby",
  "rust",
  "scss",
  "svelte",
  "toml",
  "tsx",
  "typst",
  "vim",
  "vimdoc",
  "vue",
  "yaml",
}
treesitter.install(ensure_installed)

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("dotfiles.treesitter", { clear = true }),
  callback = function(args)
    if not treesitter then
      return
    end

    local ignored_fts = {
      "codecompanion",
      "csv",
      "prompt",
      "snacks_dashboard",
      "snacks_input",
      "snacks_picker_input",
    }

    if vim.tbl_contains(ignored_fts, args.match) then
      return
    end

    pcall(vim.treesitter.start, args.buf)
  end,
})

require("nvim-autopairs").setup({
  disable_filetype = { "codecompanion" },
})
