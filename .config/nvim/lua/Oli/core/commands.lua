local M = {}
-----------------------------------DEFAULT---------------------------------- {{{
function M.default_commands()
  return {
    {
      "LineNumbers",
      function() om.ToggleLineNumbers() end,
      description = "Toggle line numbers",
    },
    {
      "ChangeFiletype",
      function() om.ChangeFiletype() end,
      description = "Change filetype of current buffer",
    },
    {
      "CopyMessage",
      function() vim.cmd([[let @+ = execute('messages')]]) end,
      description = "Copy message output",
    },
    {
      "Sessions",
      function() vim.cmd([[Telescope persisted]]) end,
      description = "Session: List",
    },
    {
      "Snippets",
      function() om.EditSnippet() end,
      description = "Edit Snippets",
    },
    {
      "TestAll",
      function() om.RunTestSuiteAsync() end,
      description = "Test all",
    },
    {
      "Theme",
      function() om.ToggleTheme() end,
      description = "Toggle theme",
    },
    {
      "Uuid",
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
  }
end

---------------------------------------------------------------------------- }}}
-----------------------------------PLUGINS---------------------------------- {{{
function M.plugin_commands()
  return {
    -- Alpha
    {
      ":Alpha",
      description = "Show the Alpha dashboard",
    },
    -- Colorizer
    {
      ":ColorizerToggle",
      description = "Colorizer toggle",
    },
    -- Coverage
    {
      "Coverage Toggle",
      function() require("coverage").toggle() end,
      description = "Coverage: Toggle",
    },
    {
      "Coverage Load",
      function() require("coverage").load(true) end,
      description = "Coverage: Load",
    },
    {
      "Coverage Clear",
      function() require("coverage").clear() end,
      description = "Coverage: Clear",
    },
    {
      "Coverage Summary",
      function() require("coverage").summary() end,
      description = "Coverage: Summary",
    },
    -- Lazygit
    {
      "Lazygit",
      function() om.Lazygit():toggle() end,
      description = "Lazygit",
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
    -- Neotest
    {
      ":NeotestOutput",
      description = "Open test output",
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
    -- Packer
    {
      "PackerCompile",
      function()
        require(config_namespace .. ".plugins.packer")
        require("packer").compile()
      end,
      description = "Packer: Compile",
    },
    {
      "PackerClean",
      function()
        require(config_namespace .. ".plugins.packer")
        require("packer").clean()
      end,
      description = "Packer: Clean",
    },
    {
      "PackerSync",
      function() om.PackerSync() end,
      description = "Packer: Sync",
    },
    {
      "PackerStatus",
      function()
        require(config_namespace .. ".plugins.packer")
        require("packer").status()
      end,
      description = "Packer: Status",
    },
    {
      "PackerSnapshot",
      function()
        local snapshot = os.date("!%Y-%m-%d %H_%M_%S")
        require(config_namespace .. ".plugins")
        require("packer").snapshot(snapshot)
      end,
      description = "Packer: Create Snapshot",
    },
    {
      "PackerSnapshotDelete",
      function()
        om.select("Delete snapshot", om.GetSnapshots(), function(choice)
          if choice == nil then return end
          require(config_namespace .. ".plugins")
          require("packer.snapshot").delete(om.path_to_snapshots .. choice)
        end)
      end,
      description = "Packer: Delete Snapshot",
    },
    {
      "PackerRollback",
      function()
        require(config_namespace .. ".plugins")
        vim.cmd("PackerRollback")
      end,
      description = "Packer: Rollback Snapshot",
    },
    -- Persisted
    {
      ":SessionSave",
      description = "Session: Save",
    },
    {
      ":SessionStart",
      description = "Session: Start",
    },
    {
      ":SessionStop",
      description = "Session: Stop",
    },
    {
      ":SessionDelete",
      description = "Session: Delete",
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
-------------------------------------LSP------------------------------------ {{{
function M.lsp_commands()
  local commands = {
    {
      "LspInstallAll",
      function()
        for _, name in pairs(om.lsp.servers) do
          vim.cmd("LspInstall " .. name)
        end
      end,
      description = "LSP: Install all servers",
    },
    {
      ":LspUninstallAll",
      description = "LSP: Uninstall all servers",
    },
    {
      "LspLog",
      function() vim.cmd("edit " .. vim.lsp.get_log_path()) end,
      description = "LSP: Show logs",
    },
  }

  return commands
end

function M.lsp_client_commands(client, bufnr)
  local commands = {
    {
      ":LspRestart",
      description = "LSP: Restart any attached clients",
      opts = { buffer = bufnr },
    },
    {
      ":LspStart",
      description = "LSP: Start the client manually",
      opts = { buffer = bufnr },
    },
    {
      ":LspInfo",
      description = "LSP: Show attached clients",
      opts = { buffer = bufnr },
    },
  }

  return commands
end

---------------------------------------------------------------------------- }}}
return M
