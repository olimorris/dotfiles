---------------------------------LOAD CONFIG-------------------------------- {{{
LockPlugins = false -- To prevent rogue updates, lock the plugins

-- Call the cache plugin
pcall(require, "impatient")

local core_modules = {
  config_namespace .. ".core.utils",
  config_namespace .. ".core.options",
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

-- Defer the plugins to last as we have packer compiled
vim.defer_fn(function()
  require(config_namespace .. ".core.plugins").load()
end, 0)
--------------------------------------------------------------------------- }}}
----------------------------LOAD NEOVIM MAPPINGS---------------------------- {{{
local ok, mappings = om.safe_require(config_namespace .. ".core.mappings")
if ok then
  mappings.neovim()
end
--------------------------------------------------------------------------- }}}
---------------------------------LOAD THEME--------------------------------- {{{
vim.o.background = "dark"
local ok, theme = om.safe_require(config_namespace .. ".core.theme")
if ok then
  theme.init()
end

---TESTING ONEDARKPRO
---TEST CASE #1
-- vim.o.background = "dark"
-- require('onedarkpro').load()
---TEST CASE #2
-- vim.cmd [[ colorscheme onedarkpro ]]
-- vim.cmd [[ colorscheme default ]]
-- vim.cmd [[ colorscheme onedarkpro ]]
--------------------------------------------------------------------------- }}}
