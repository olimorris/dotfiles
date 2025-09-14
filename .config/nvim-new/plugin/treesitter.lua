local treesitter = require("nvim-treesitter")

-- Some default parsers that I always want installed
local ensure_installed = {
  "css",
  "csv",
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
  "norg",
  "regex",
  "ruby",
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

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("dotfiles.pack", { clear = true }),
  callback = function(args)
    local spec = args.data.spec
    if spec and spec.name == "nvim-treesitter" and args.data.kind == "update" then
      vim.schedule(function()
        treesitter.update()
      end)
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("dotfiles.treesitter", { clear = true }),
  callback = function(args)
    if not treesitter then
      return
    end

    local ignored_fts = {
      "prompt",
      "snacks_dashboard",
      "snacks_input",
      "snacks_picker_input",
    }

    if vim.tbl_contains(ignored_fts, args.match) then
      return
    end

    local ft = vim.bo[args.buf].ft
    local lang = vim.treesitter.language.get_lang(ft)
    treesitter.install({ lang }):await(function(err)
      if err then
        vim.notify("Could not install Tree-sitter parser for " .. ft .. ". Err:\n" .. err)
        return
      end

      pcall(vim.treesitter.start, args.buf)
    end)
  end,
})

require("nvim-autopairs").setup({
  disable_filetype = { "codecompanion" },
})
