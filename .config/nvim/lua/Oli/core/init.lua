---------------------------------LOAD CONFIG-------------------------------- {{{
LockPlugins = false -- To prevent rogue updates, lock the plugins

local core_modules = {
  config_namespace .. ".core.utils",
  config_namespace .. ".core.options",
  config_namespace .. ".core.plugins",
  config_namespace .. ".core.functions",
  config_namespace .. ".core.autocmds",
}
for _, module in ipairs(core_modules) do
  local ok, result = pcall(require, module)
  if not ok then
    vim.notify(result, vim.log.levels.ERROR, {
      title = string.format("Error requiring: %s \n\n", module),
    })
  end
end
--------------------------------------------------------------------------- }}}
----------------------------LOAD NEOVIM MAPPINGS---------------------------- {{{
local ok, mappings = om.safe_require(config_namespace .. ".core.mappings")
if ok then
  mappings.neovim()
end
--------------------------------------------------------------------------- }}}
---------------------------------LOAD THEME--------------------------------- {{{
vim.o.background = "light"
local ok, theme = om.safe_require(config_namespace .. ".core.theme")
if ok then
  theme.init()
end

---TESTING ONEDARKPRO
---TEST CASE #1
-- vim.o.background = "light"
-- require('onedarkpro').load()
---TEST CASE #2
-- vim.cmd [[ colorscheme onedarkpro ]]
-- vim.cmd [[ colorscheme default ]]
-- vim.cmd [[ colorscheme onedarkpro ]]
--------------------------------------------------------------------------- }}}
