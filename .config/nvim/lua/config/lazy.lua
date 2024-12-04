require("config.util")
require("config.options")

-- Begin Lazy install and plugin setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  dev = {
    path = "~/Code/Neovim",
    -- Only load my local plugins when we're on my machine
    patterns = (jit.os == "OSX") and { "olimorris" } or {},
  },
  checker = {
    enabled = true,
    notify = false,
    frequency = 900,
  },
  change_detection = {
    enabled = true,
    notify = false,
  },
  install = {
    colorscheme = { "onedark", "onelight" },
  },
  ui = {
    border = "single",
    icons = {
      plugin = "",
    },
  },
  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- Load functions next as our plugins and autocmds require them
require("config.functions")

-- Autocmds and keymaps can be loaded, lazily, after plugins
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    require("config.commands")
    require("config.keymaps")
  end,
})
