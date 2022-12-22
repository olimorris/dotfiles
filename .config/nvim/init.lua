-- Reload functions to enable hot-reloading...sort of
-- https://github.com/akinsho/dotfiles/blob/main/.config/nvim/init.lua
local ok, reload = pcall(require, "plenary.reload")
RELOAD = ok and reload.reload_module or function(...) return ... end
function R(name)
  RELOAD(name)
  return require(name)
end

-- We namespace the config so that when we reload our modules more easily
-- Ref: https://www.reddit.com/r/neovim/comments/puuskh/comment/he5vnqc
_G.config_namespace = "Oli"

-- Load the configuration
R(config_namespace .. ".core.globals")
R(config_namespace .. ".core.options")
R(config_namespace .. ".core.functions")
R(config_namespace .. ".plugins")
