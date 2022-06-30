local PACKER_INSTALLED_PATH = vim.fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"
------------------------------PACKER BOOTSTRAP------------------------------ {{{
if vim.fn.empty(vim.fn.glob(PACKER_INSTALLED_PATH)) > 0 then
  vim.notify("Downloading packer.nvim...", nil, { title = "Packer" })
  PACKER_BOOTSTRAP = vim.fn.system({
    "git",
    "clone",
    "https://github.com/wbthomason/packer.nvim",
    "--depth",
    "20",
    PACKER_INSTALLED_PATH,
  })
  vim.cmd([[packadd packer.nvim]])
end
---------------------------------------------------------------------------- }}}
---------------------------------PACKER INIT-------------------------------- {{{
local present, packer = pcall(require, "packer")
if not present then
  return
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
  ensure_dependencies = true,
  compile_on_sync = true,
  max_jobs = 30,
})
---------------------------------------------------------------------------- }}}
return packer
