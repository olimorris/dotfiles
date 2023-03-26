local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
  spec = { import = config_namespace .. ".plugins" },
  dev = {
    path = "~/Code/Neovim",
    -- Only load my local plugins when we're on my machine
    patterns = (jit.os == "OSX" and vim.fn.hostname() == "Oli") and { "olimorris" } or {},
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
