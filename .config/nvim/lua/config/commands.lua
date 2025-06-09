local commands = {
  {
    "LineNumbers",
    "Toggle line numbers",
    function()
      om.ToggleLineNumbers()
    end,
  },
  {
    "ChangeFiletype",
    "Change filetype of current buffer",
    function()
      om.ChangeFiletype()
    end,
  },
  {
    "CopyMessage",
    "Copy message output",
    function()
      vim.cmd([[let @+ = execute('messages')]])
    end,
  },
  {
    "FindAndReplace",
    "Find and Replace (after quickfix)",
    function(opts)
      vim.api.nvim_command(string.format("silent cdo s/%s/%s", opts.fargs[1], opts.fargs[2]))
      vim.api.nvim_command("silent cfdo update")
    end,
    opts = { nargs = "*" },
  },
  {
    "FindAndReplaceUndo",
    "Undo Find and Replace",
    function(opts)
      vim.api.nvim_command("silent cdo undo")
    end,
  },
  {
    "GitBranchList",
    "List the Git branches in this repo",
    function()
      om.ListBranches()
    end,
  },
  {
    "GitRemoteSync",
    "Git sync remote repo",
    function()
      om.GitRemoteSync()
    end,
  },
  {
    "New",
    "New buffer",
    ":enew",
  },
  {
    "Snippets",
    "Edit Snippets",
    function()
      om.EditSnippet()
    end,
  },
  {
    "Theme",
    "Toggle theme",
    function()
      om.ToggleTheme()
    end,
  },
  {
    "Uuid",
    "Generate a UUID and insert it into the buffer",
    function()
      local uuid = vim.fn.system("uuidgen"):gsub("\n", ""):lower()
      local line = vim.fn.getline(".")
      vim.schedule(function()
        vim.fn.setline(".", vim.fn.strpart(line, 0, vim.fn.col(".")) .. uuid .. vim.fn.strpart(line, vim.fn.col(".")))
      end)
    end,
  },
}

for _, cmd in ipairs(commands) do
  om.create_user_command(cmd[1], cmd[2], cmd[3], cmd.opts)
end
