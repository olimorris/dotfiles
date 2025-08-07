vim.pack.add({
  gh("windwp/nvim-autopairs"),
  gh("windwp/nvim-ts-autotag"),
  gh("JoosepAlviste/nvim-ts-context-commentstring"),
  { src = gh("nvim-treesitter/nvim-treesitter"), branch = "main" },
  { src = gh("nvim-treesitter/nvim-treesitter-textobjects"), branch = "main" },
})

--=============================================================================
-- Plugin Setup
--=============================================================================
require("nvim-autopairs").setup({
  disable_filetype = { "codecompanion" },
})

--=============================================================================
-- Keymaps
--=============================================================================
local opts = { noremap = true, silent = true }

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

--=============================================================================
-- Autocmds
--=============================================================================
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function()
    vim.cmd("TSUpdate")
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local filetype = args.match
    local lang = vim.treesitter.language.get_lang(filetype)
    if vim.treesitter.language.add(lang) then
      vim.treesitter.start()
    end
  end,
})
