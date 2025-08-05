local opts = { noremap = true, silent = true }

require("nvim-treesitter").install({
  "c",
  "cmake",
  "cpp",
  "csv",
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
})
require("nvim-treesitter").update()

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local filetype = args.match
    local lang = vim.treesitter.language.get_lang(filetype)
    if vim.treesitter.language.add(lang) then
      vim.treesitter.start()
    end
  end,
})

om.set_keymaps("af", function()
  require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
end, { "x", "o" }, opts)
om.set_keymaps("if", function()
  require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
end, { "x", "o" }, opts)
om.set_keymaps("ac", function()
  require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
end, { "x", "o" }, opts)
om.set_keymaps("ic", function()
  require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
end, { "x", "o" }, opts)
om.set_keymaps("as", function()
  require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
end, { "x", "o" }, opts)

require("nvim-autopairs").setup({
  Check_ts = true,
  enable_moveright = true,
  fast_wrap = {
    map = "<c-e>",
  },
})
