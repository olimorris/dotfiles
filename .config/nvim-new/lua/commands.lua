local command = vim.api.nvim_create_user_command --[[@type function]]

command("LineNumbers", function()
  om.ToggleLineNumbers()
end, { desc = "Toggle line numbers" })

command("ChangeFiletype", function()
  om.ChangeFiletype()
end, { desc = "Change filetype of current buffer" })

command("CopyMessage", function()
  vim.cmd([[let @+ = execute('messages')]])
end, { desc = "Copy message output" })

command("FindAndReplace", function(opts)
  vim.api.nvim_command(string.format("silent cdo s/%s/%s", opts.fargs[1], opts.fargs[2]))
  vim.api.nvim_command("silent cfdo update")
end, { desc = "Find and Replace (after quickfix)", nargs = "*" })

command("FindAndReplaceUndo", function(opts)
  vim.api.nvim_command("silent cdo undo")
end, { desc = "Undo Find and Replace" })

command("GitBranchList", function()
  om.ListBranches()
end, { desc = "List the Git branches in this repo" })

command("GitRemoteSync", function()
  om.GitRemoteSync()
end, { desc = "Git sync remote repo" })

command("New", ":enew", { desc = "New buffer" })

command("PackSync", function()
  local plugins = {}
  for _, plugin in ipairs(om.plugins) do
    if type(plugin) == "string" then
      plugins[plugin] = true
    elseif type(plugin) == "table" and plugin.src then
      plugins[plugin.src] = true
    end
  end

  local to_delete = {}
  for _, plugin in ipairs(vim.pack.get()) do
    local src = plugin.spec and plugin.spec.src
    if src and not plugins[src] then
      table.insert(to_delete, plugin.spec.name)
    end
  end

  vim.pack.del(to_delete)
  vim.pack.add(om.plugins)
  vim.pack.update()
end, { desc = "Sync plugins" })

command("Snippets", function()
  om.EditSnippet()
end, { desc = "Edit Snippets" })

command("Theme", function()
  om.ToggleTheme()
end, { desc = "Toggle theme" })

command("Sessions", function()
  require("persisted").select()
end, { desc = "List Sessions" })
