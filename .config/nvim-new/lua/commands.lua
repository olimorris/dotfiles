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
  api.nvim_command(string.format("silent cdo s/%s/%s", opts.fargs[1], opts.fargs[2]))
  api.nvim_command("silent cfdo update")
end, { desc = "Find and Replace (after quickfix)", nargs = "*" })

command("FindAndReplaceUndo", function(opts)
  api.nvim_command("silent cdo undo")
end, { desc = "Undo Find and Replace" })

command("GitBranchList", function()
  om.ListBranches()
end, { desc = "List the Git branches in this repo" })

command("GitRemoteSync", function()
  om.GitRemoteSync()
end, { desc = "Git sync remote repo" })

command("New", ":enew", { desc = "New buffer" })

command("Snippets", function()
  om.EditSnippet()
end, { desc = "Edit Snippets" })

command("Theme", function()
  om.ToggleTheme()
end, { desc = "Toggle theme" })

command("Sessions", function()
  require("persisted").select()
end, { desc = "List Sessions" })
