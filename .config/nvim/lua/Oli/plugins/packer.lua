vim.cmd("packadd packer.nvim")

local PACKER_INSTALLED_PATH = vim.fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"

local present, packer = pcall(require, "packer")

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
    return
  end

  require(config_namespace .. ".plugins")
  packer.sync()
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
})

return packer
