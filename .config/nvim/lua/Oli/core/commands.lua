local M = {}
------------------------------DEFAULT COMMANDS------------------------------ {{{
function M.default_commands()
  return {
    -- Custom
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
            vim.fn.setline(
              ".",
              vim.fn.strpart(line, 0, vim.fn.col(".")) .. uuid .. vim.fn.strpart(line, vim.fn.col("."))
            )
          end
        )
      end,
      description = "Generate a UUID and insert it into the buffer",
    },

    -- Plugins

    -- Alpha
    {
      ":Alpha",
      description = "Show the Alpha dashboard",
    },
    -- Barbecue
    {
      ":Barbecue toggle",
      description = "Toggle Barbecue's winbar",
    },
    -- Colorizer
    {
      ":ColorizerToggle",
      description = "Colorizer toggle",
    },
    -- Comment.nvim
    {
      ":Comment",
      {
        n = "gcc",
        v = "gc",
      },
      description = "Toggle comment",
    },
    -- Copilot
    {
      itemgroup = "Copilot",
      commands = {
        {
          ":CopilotToggle",
          function() require("copilot.suggestion").toggle_auto_trigger() end,
          description = "Toggle on/off for buffer",
        },
      },
    },
    -- Coverage
    {
      itemgroup = "Testing",
      commands = {
        {
          ":NeotestOutput",
          description = "Neotest: Open test output",
        },
        {
          "Coverage",
          function() require("coverage").toggle() end,
          description = "Coverage: Toggle",
        },
        {
          "CoverageLoad",
          function() require("coverage").load(true) end,
          description = "Coverage: Load",
        },
        {
          "CoverageClear",
          function() require("coverage").clear() end,
          description = "Coverage: Clear",
        },
        {
          "CoverageSummary",
          function() require("coverage").summary() end,
          description = "Coverage: Summary",
        },
      },
    },
    -- Git
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
    -- Lazygit
    {
      "Lazygit",
      function() om.Lazygit():toggle() end,
      description = "Git terminal",
    },
    -- Mason
    {
      ":Mason",
      description = "Open Mason",
    },
    {
      ":MasonUninstallAll",
      description = "Uninstall all Mason packages",
    },
    -- neogen
    {
      ":Neogen",
      description = "Generate annotation",
    },
    -- OnedarkPro
    {
      ":OnedarkproCache",
      description = "Cache the theme",
    },
    {
      ":OnedarkproClean",
      description = "Clean the theme cache",
    },
    {
      ":OnedarkproColors",
      description = "Show the theme's colors",
    },
    -- Lazy.nvim
    {
      itemgroup = "Lazy.nvim",
      icon = "",
      description = "Commands for the Lazy package manager",
      commands = {
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
      },
    },
    -- Persisted
    {
      itemgroup = "Persisted",
      commands = {
        {
          ":Sessions",
          function() vim.cmd([[Telescope persisted]]) end,
          description = "List sessions",
        },
        {
          ":SessionSave",
          description = "Save the session",
        },
        {
          ":SessionStart",
          description = "Start a session",
        },
        {
          ":SessionStop",
          description = "Stop the current session",
        },
        {
          ":SessionDelete",
          description = "Delete the current session",
        },
      },
    },

    -- Satellite
    {
      ":SatelliteEnable",
      description = "Enable satellite scrollbar",
    },
    {
      ":SatelliteDisable",
      description = "Disable satellite scrollbar",
    },
    {
      ":SatelliteRefresh",
      description = "Refresh satellite scrollbar",
    },
    -- Startup time
    {
      ":StartupTime",
      description = "Profile Neovim's startup time",
    },
    -- Treesitter
    {
      ":TSPlayground",
      description = "Treesitter Playground",
    },
  }
end

---------------------------------------------------------------------------- }}}
--------------------------------LSP COMMANDS-------------------------------- {{{
function M.lsp_commands(client, bufnr)
  -- Only need to set these once!
  if vim.g.lsp_commands then return {} end

  local commands = {
    {
      ":Format",
      function() vim.lsp.buf.format(nil, 1000) end,
      description = "Format buffer",
    },
    {
      ":LspRestart",
      description = "Restart any attached clients",
    },
    {
      ":LspStart",
      description = "Start the client manually",
    },
    {
      ":LspInfo",
      description = "Show attached clients",
    },
    {
      "LspInstallAll",
      function()
        for _, name in pairs(om.lsp.servers) do
          vim.cmd("LspInstall " .. name)
        end
      end,
      description = "Install all servers",
    },
    {
      "LspUninstallAll",
      description = "Uninstall all servers",
    },
    {
      "LspLog",
      function() vim.cmd("edit " .. vim.lsp.get_log_path()) end,
      description = "Show logs",
    },
    {
      "NullLsInstall",
      description = "null-ls: Install plugins",
    },
  }

  vim.g.lsp_commands = true

  return {
    itemgroup = "LSP",
    commands = commands,
  }
end

---------------------------------------------------------------------------- }}}
return M
