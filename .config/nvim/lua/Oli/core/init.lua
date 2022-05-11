local core_modules = {
  config_namespace .. ".core.globals",
  config_namespace .. ".core.options",
  config_namespace .. ".core.functions",
}

for _, module in ipairs(core_modules) do
  local ok, err = pcall(load, module)
  if not ok then
    vim.notify(err, vim.log.levels.ERROR, {
      title = string.format("Error requiring: %s \n\n", module),
    })
  end
end
