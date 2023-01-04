-- We namespace the config so that when we reload our modules more easily
-- Ref: https://www.reddit.com/r/neovim/comments/puuskh/comment/he5vnqc
_G.config_namespace = "Oli"

require(config_namespace .. ".utils.globals")
require(config_namespace .. ".utils.functions")
require(config_namespace .. ".options")
require(config_namespace .. ".lazy")

if vim.o.background == "light" then
  vim.cmd([[colorscheme onelight]])
else
  vim.cmd([[colorscheme onedark]])
end
