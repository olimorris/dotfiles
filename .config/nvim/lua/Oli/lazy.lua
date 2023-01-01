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
  dev = {
    path = "~/Code/Neovim",
    patterns = { "olimorris" },
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

local ok, legendary = om.safe_require("legendary")
if not ok then return end

legendary.commands({
  {
    itemgroup = "Lazy.nvim",
    icon = "",
    description = "Commands for the Lazy package manager",
    commands = {
      {
        ":Lazy",
        description = "Open Lazy",
      },
      {
        ":Lazy sync",
        description = "Install, clean and update",
      },
      {
        ":Lazy clean",
        description = "Clean",
      },
      {
        ":Lazy restore",
        description = "Restores plugins to the state in the lockfile",
      },
      {
        ":Lazy profile",
        description = "Profile",
      },
      {
        ":Lazy log",
        description = "Log",
      },
    },
  },
})
