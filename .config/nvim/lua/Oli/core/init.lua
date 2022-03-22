LockPlugins = false -- To prevent rogue updates, lock the plugins

-- Call the cache plugin
pcall(require, "impatient")

local core_modules = {
  config_namespace .. ".core.globals",
  config_namespace .. ".core.options",
  config_namespace .. ".core.functions",
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
