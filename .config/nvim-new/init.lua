_G.om = {}
om.home = os.getenv("HOME")
om.nvim_start_time = vim.uv.hrtime()
om.on_personal = vim.fn.getenv("USER") == "Oli"
om.on_big_screen = vim.o.columns > 150 and vim.o.lines >= 40

-- Local plugins
vim.cmd(string.format("set rtp+=%s", om.home .. "/Code/Neovim/persisted.nvim"))
vim.cmd(string.format("set rtp+=%s", om.home .. "/Code/Neovim/onedarkpro.nvim"))
vim.cmd(string.format("set rtp+=%s", om.home .. "/Code/Neovim/onedarkpro.nvim/after")) -- Needed for TS queries
vim.cmd(string.format("set rtp+=%s", om.home .. "/Code/Neovim/codecompanion.nvim"))

om.plugins = {
  -- Dependencies
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",

  -- UI and Statusline
  "https://github.com/folke/edgy.nvim",
  "https://github.com/tpope/vim-sleuth",
  "https://github.com/folke/snacks.nvim",
  "https://github.com/j-hui/fidget.nvim",
  "https://github.com/rebelot/heirline.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/folke/todo-comments.nvim",
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",

  -- LSP
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/stevearc/conform.nvim",

  -- Editor
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/nvim-mini/mini.test",
  "https://github.com/stevearc/aerial.nvim",
  "https://github.com/stevearc/overseer.nvim",
  "https://github.com/kylechui/nvim-surround",

  -- Completion
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("^1") },

  -- Tree-sitter
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/RRethy/nvim-treesitter-endwise",
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
}

vim.pack.add(om.plugins)

require("config")
require("keymaps")
require("autocmds")
require("commands")
require("functions")
