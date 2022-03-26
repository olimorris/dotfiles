----------------------------------BOOTSTRAP--------------------------------- {{{
local PACKER_COMPILED_PATH = vim.fn.stdpath("cache") .. "/packer/packer_compiled.lua"
local PACKER_INSTALLED_PATH = vim.fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"

local function has_packer()
  return vim.fn.empty(vim.fn.glob(PACKER_INSTALLED_PATH)) == 0
end

local function install_packer()
  vim.fn.delete(PACKER_INSTALLED_PATH, "rf")
  vim.fn.delete(PACKER_COMPILED_PATH, "rf")

  vim.notify("Downloading packer.nvim...", nil, { title = "Packer" })
  vim.notify(
    vim.fn.system({
      "git",
      "clone",
      "https://github.com/wbthomason/packer.nvim",
      PACKER_INSTALLED_PATH,
    }),
    nil,
    { title = "Packer" }
  )
end

local function add_packer()
  local packer, error_msg = pcall(vim.cmd, [[packadd! packer.nvim]])
  if not packer then
    vim.notify(error_msg, nil, { title = "Packer" })
    return
  end
end

local function init_packer()
  require("packer").init()
end

-- Get a list of plugins and use them
local function setup_plugins()
  require("packer").startup({
    function(use, use_rocks)
      -- Packer manages itself
      use({
        "wbthomason/packer.nvim",
        event = "VimEnter",
      })
      use_rocks("penlight")

      for _, plugin in ipairs(require(config_namespace .. ".plugins")) do
        use(plugin)
      end
    end,
    log = { level = "info" },
    config = {
      display = {
        open_fn = function()
          return require("packer.util").float({ border = "single" })
        end,
      },
      git = {
        clone_timeout = 60, -- Timeout for git clones (seconds)
      },
      auto_clean = true,
      compile_on_sync = true,
      profile = {
        enable = true,
        threshold = 1, -- the amount in ms that a plugins load time must be over for it to be included in the profile
      },
    },
  })
end
---------------------------------------------------------------------------- }}}
------------------------------------SETUP----------------------------------- {{{
local M = {}

M.load = function()
  if not has_packer() then
    install_packer()
    add_packer()
    setup_plugins()
    vim.cmd("au User PackerComplete echom 'Plugins are installed successfully, please use :qa to restart the neovim'")
    require("packer").sync()
    return
  end

  add_packer()
  -- init_packer()
  setup_plugins()
end

return M
---------------------------------------------------------------------------- }}}
