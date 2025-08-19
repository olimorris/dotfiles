local ts = require("nvim-treesitter")

local ensure_installed = {
  "css",
  "csv",
  "diff",
  "gitcommit",
  "gitignore",
  "go",
  "fish",
  "html",
  "javascript",
  "json",
  "latex",
  "ledger",
  "lua",
  "markdown",
  "markdown_inline",
  "norg",
  "php",
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

ts.install(ensure_installed)

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("dotfiles.pack", { clear = true }),
  callback = function(args)
    local spec = args.data.spec
    if spec and spec.name == "nvim-treesitter" and args.data.kind == "update" then
      vim.schedule(function()
        ts.update()
      end)
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua" },
  group = vim.api.nvim_create_augroup("dotfiles.treesitter", { clear = true }),
  callback = function()
    vim.treesitter.start()
  end,
})

require("nvim-autopairs").setup({
  disable_filetype = { "codecompanion" },
})
