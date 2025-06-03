local commands = {
  {
    "LineNumbers",
    function()
      om.ToggleLineNumbers()
    end,
    desc = "Toggle line numbers",
  },
  {
    "ChangeFiletype",
    function()
      om.ChangeFiletype()
    end,
    desc = "Change filetype of current buffer",
  },
  {
    "CopyMessage",
    function()
      vim.cmd([[let @+ = execute('messages')]])
    end,
    desc = "Copy message output",
  },
  {
    "FindAndReplace",
    function(opts)
      vim.api.nvim_command(string.format("silent cdo s/%s/%s", opts.fargs[1], opts.fargs[2]))
      vim.api.nvim_command("silent cfdo update")
    end,
    desc = "Find and Replace (after quickfix)",
    opts = { nargs = "*" },
  },
  {
    "FindAndReplaceUndo",
    function(opts)
      vim.api.nvim_command("silent cdo undo")
    end,
    desc = "Undo Find and Replace",
  },
  {
    "GitBranchList",
    function()
      om.ListBranches()
    end,
    desc = "List the Git branches in this repo",
  },
  {
    "GitRemoteSync",
    function()
      om.GitRemoteSync()
    end,
    desc = "Git sync remote repo",
  },
  {
    "New",
    ":enew",
    desc = "New buffer",
  },
  {
    "Snippets",
    function()
      om.EditSnippet()
    end,
    desc = "Edit Snippets",
  },
  {
    "Theme",
    function()
      om.ToggleTheme()
    end,
    desc = "Toggle theme",
  },
  {
    "Uuid",
    function()
      local uuid = vim.fn.system("uuidgen"):gsub("\n", ""):lower()
      local line = vim.fn.getline(".")
      vim.schedule(function()
        vim.fn.setline(".", vim.fn.strpart(line, 0, vim.fn.col(".")) .. uuid .. vim.fn.strpart(line, vim.fn.col(".")))
      end)
    end,
    desc = "Generate a UUID and insert it into the buffer",
  },
}

for _, cmd in ipairs(commands) do
  om.create_user_command(cmd[1], cmd[2], cmd.desc, cmd.opts)
end
