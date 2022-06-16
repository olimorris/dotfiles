vim.cmd("packadd packer.nvim")

local PACKER_INSTALLED_PATH = vim.fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"

local present, packer = pcall(require, "packer")
local plugins = require(config_namespace .. ".plugins").plugins
local lua_rocks = require(config_namespace .. ".plugins").lua_rocks

if not present then
  vim.notify("Downloading packer.nvim...", nil, { title = "Packer" })
  vim.fn.system({
    "git",
    "clone",
    "https://github.com/wbthomason/packer.nvim",
    "--depth",
    "20",
    PACKER_INSTALLED_PATH,
  })
  vim.cmd("packadd packer.nvim")
  present, packer = pcall(require, "packer")

  if present then
    vim.notify("Packer downloaded successfully", nil, { title = "Packer" })
  else
    vim.notify("Couldn't download Packer", nil, { title = "Packer" })
  end
end

packer.init({
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "single" })
    end,
    prompt_border = "single",
  },
  git = {
    clone_timeout = 240, -- Timeout for git clones (seconds)
  },
  auto_clean = true,
  compile_on_sync = true,
  max_jobs = 15,
  compile_path = PACKER_COMPILED_PATH,
  snapshot_path = PACKER_SNAPSHOT_PATH,
  log = { level = "warn" },
})

return packer.startup(function(use, use_rock)
  for _, plugins in ipairs(plugins) do
    use(plugins)
  end
  for _, lua_rocks in ipairs(lua_rocks) do
    use_rock(lua_rocks)
  end
end)
