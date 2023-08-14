local ok, legendary = pcall(require, "legendary")
if not ok then return end

return legendary.commands({
  {
    ":LineNumbers",
    function() om.ToggleLineNumbers() end,
    description = "Toggle line numbers",
  },
  {
    ":ChangeFiletype",
    function() om.ChangeFiletype() end,
    description = "Change filetype of current buffer",
  },
  {
    ":CopyMessage",
    function() vim.cmd([[let @+ = execute('messages')]]) end,
    description = "Copy message output",
  },
  {
    ":copen",
    description = "Open quickfix window",
  },
  {
    ":cclose",
    description = "Close quickfix window",
  },
  {
    itemgroup = "Find and Replace (Global)",
    icon = "",
    description = "Find and replace across the project",
    commands = {
      {
        "FindAndReplace",
        function(opts)
          vim.api.nvim_command(string.format("silent cdo s/%s/%s", opts.fargs[1], opts.fargs[2]))
          vim.api.nvim_command("silent cfdo update")
        end,
        description = "Find and Replace (after quickfix)",
        unfinished = true,
        opts = { nargs = "*" },
      },
      {
        "FindAndReplaceUndo",
        function(opts) vim.api.nvim_command("silent cdo undo") end,
        description = "Undo Find and Replace",
      },
    },
  },
  {
    "GitBranchList",
    function() om.ListBranches() end,
    description = "List the Git branches in this repo",
  },
  {
    "GitRemoteSync",
    function() om.GitRemoteSync() end,
    description = "Git sync remote repo",
  },
  {
    itemgroup = "Lazy.nvim",
    icon = "",
    description = "Commands for the Lazy package manager",
    commands = {
      {
        ":Lazy",
        description = "Open Lazy",
      },
      {
        ":Lazy sync",
        description = "Install, clean and update",
      },
      {
        ":Lazy clean",
        description = "Clean",
      },
      {
        ":Lazy restore",
        description = "Restores plugins to the state in the lockfile",
      },
      {
        ":Lazy profile",
        description = "Profile",
      },
      {
        ":Lazy log",
        description = "Log",
      },
    },
  },
  {
    "Lazygit",
    function() om.float_term("lazygit", { size = { width = 1, height = 1 } }) end,
    description = "Git terminal",
  },
  {
    ":New",
    ":enew",
    description = "New buffer",
  },
  {
    ":Snippets",
    function() om.EditSnippet() end,
    description = "Edit Snippets",
  },
  {
    ":Theme",
    function() om.ToggleTheme() end,
    description = "Toggle theme",
  },
  {
    ":Uuid",
    function()
      local uuid = vim.fn.system("uuidgen"):gsub("\n", ""):lower()
      local line = vim.fn.getline(".")
      vim.schedule(
        function()
          vim.fn.setline(".", vim.fn.strpart(line, 0, vim.fn.col(".")) .. uuid .. vim.fn.strpart(line, vim.fn.col(".")))
        end
      )
    end,
    description = "Generate a UUID and insert it into the buffer",
  },
})
