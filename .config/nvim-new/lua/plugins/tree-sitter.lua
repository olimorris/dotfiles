local ts = require("nvim-treesitter")
ts.setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
})

local ensure_installed = {
  "diff",
  "gitcommit",
  "gitignore",
  "go",
  "fish",
  "html",
  "json",
  "ledger",
  "lua",
  "markdown",
  "markdown_inline",
  "php",
  "python",
  "ruby",
  "rust",
  "toml",
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
  group = vim.api.nvim_create_augroup("dotfiles.treesitter", { clear = true }),
  callback = function(args)
    local filetype = args.match
    local lang = vim.treesitter.language.get_lang(filetype)
    if not lang then
      return
    end

    if vim.treesitter.language.add(lang) then
      vim.treesitter.start(args.buf)
    end
  end,
})

require("nvim-autopairs").setup({
  disable_filetype = { "codecompanion" },
})
