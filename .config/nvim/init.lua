local present, impatient = pcall(require, "impatient")

if present then
  impatient.enable_profile()
end

-- Global config namespace
-- We namespace the config so that when we reload our modules it picks up all
-- the files in that scope and clears the package cache
-- Ref: https://www.reddit.com/r/neovim/comments/puuskh/comment/he5vnqc
_G.config_namespace = "Oli"

-- Allow us to use :source $MYVIMRC to reload portions of our config
_G.load = function(module)
  package.loaded[module] = nil
  return require(module)
end

local ok, _ = load(config_namespace .. ".core")

if not ok then
  vim.notify("Error: Could not load default modules")
end
