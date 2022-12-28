local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--single-branch",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.runtimepath:prepend(lazypath)

local ok, lazy = om.safe_require("lazy")
if not ok then return end

lazy.setup(config_namespace .. ".plugins", {
  checker = {
    enabled = true,
    notify = false,
    frequency = 900,
  },
  install = {
    colorscheme = { "onedark" },
  },
  ui = {
    icons = {
      plugin = "",
    },
  },
  performance = {
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
