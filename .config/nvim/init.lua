-- We namespace the config so that when we reload our modules more easily
-- Ref: https://www.reddit.com/r/neovim/comments/puuskh/comment/he5vnqc
_G.config_namespace = "Oli"

require(config_namespace .. ".util")
require(config_namespace .. ".config")
