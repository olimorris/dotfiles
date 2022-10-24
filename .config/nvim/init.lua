local ok, impatient = pcall(require, "impatient")

if ok then impatient.enable_profile() end

-- We namespace the config so that when we reload our modules more easily
-- Ref: https://www.reddit.com/r/neovim/comments/puuskh/comment/he5vnqc
_G.config_namespace = "Oli"

vim.g.core_modules = {
  config_namespace .. ".core.globals",
  config_namespace .. ".core.options",
  config_namespace .. ".core.functions",
  config_namespace .. ".plugins",
}

for _, module in ipairs(vim.g.core_modules) do
  local ok, err = pcall(require, module)
  if not ok then vim.api.nvim_err_writeln("Failed to load " .. module .. "\n\n" .. err) end
end
