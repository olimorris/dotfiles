local M = {}
-----------------------------------DEFAULT---------------------------------- {{{
function M.default_commands()
  return {
    {
      "LineNumbers",
      function()
        om.ToggleLineNumbers()
      end,
      description = "Toggle line numbers",
    },
    {
      "CopyMessage",
      function()
        vim.cmd([[let @+ = execute('messages')]])
      end,
      description = "Copy message output",
    },
    {
      "Sessions",
      function()
        vim.cmd([[Telescope persisted]])
      end,
      description = "Session: List",
    },
    {
      "Snippets",
      function()
        om.EditSnippet()
      end,
      description = "Edit Snippets",
    },
    {
      "TestAll",
      function()
        om.RunTestSuiteAsync()
      end,
      description = "Test all",
    },
    {
      "Theme",
      function()
        om.ToggleTheme()
      end,
      description = "Toggle theme",
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
      "Dashboard",
      function()
        vim.cmd([[Alpha]])
      end,
      description = "Show the Alpha dashboard",
    },
    -- Colorizer
    {
      "Color Toggle",
      function()
        vim.cmd([[ColorizerToggle]])
      end,
      description = "Colorizer toggle",
    },
    -- Coverage
    {
      "Coverage Toggle",
      function()
        require("coverage").toggle()
      end,
      description = "Coverage: Toggle",
    },
    {
      "Coverage Load",
      function()
        require("coverage").load(true)
      end,
      description = "Coverage: Load",
    },
    {
      "Coverage Clear",
      function()
        require("coverage").clear()
      end,
      description = "Coverage: Clear",
    },
    {
      "Coverage Summary",
      function()
        require("coverage").summary()
      end,
      description = "Coverage: Summary",
    },
    -- Lazygit
    {
      "Lazygit",
      function()
        om.Lazygit():toggle()
      end,
      description = "Lazygit",
    },

    -- Mason
    {
      ":Mason<CR>",
      description = "Open Mason",
    },
    {
      ":MasonUninstallAll<CR>",
      description = "Uninstall all Mason packages",
    },
    {
      "LspInstallAll",
      function()
        for _, name in pairs(om.lsp.servers) do
          vim.cmd("LspInstall " .. name)
        end
      end,
      description = "Install LSP servers",
    },
    {
      "LspUninstall",
      function()
        vim.cmd("LspUninstallAll")
      end,
      description = "Uninstall LSP servers",
    },
    -- neogen
    {
      "Neogen",
      function()
        require("neogen").generate()
      end,
      description = "Generate annotation",
    },
    -- Neotest
    {
      "NeotestOutput",
      function()
        return require("neotest").output.open()
      end,
      description = "Open test output",
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
      function()
        om.PackerSync()
      end,
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
          if choice == nil then
            return
          end
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
      "SessionSave",
      function()
        require("persisted").save()
      end,
      description = "Session: Save",
    },
    {
      "SessionStart",
      function()
        require("persisted").start()
      end,
      description = "Session: Start",
    },
    {
      "SessionStop",
      function()
        require("persisted").stop()
      end,
      description = "Session: Stop",
    },
    {
      "SessionDelete",
      function()
        require("persisted").delete()
      end,
      description = "Session: Delete",
    },
    -- Startup time
    {
      "Startup Time",
      function()
        vim.cmd([[StartupTime]])
      end,
      description = "Profile Neovim's startup time",
    },
    -- Treesitter
    {
      "Treesitter Playground",
      ":TSPlayground<CR>",
      description = "Treesitter Playground",
    },
  }
end
---------------------------------------------------------------------------- }}}
-------------------------------------LSP------------------------------------ {{{
function M.lsp_commands(client, bufnr)
  local commands = {
    {
      "LspRestart",
      description = "Restart any attached LSP clients",
      opts = { buffer = bufnr },
    },
    {
      "LspStart",
      description = "Start the LSP client manually",
      opts = { buffer = bufnr },
    },
    {
      "LspInfo",
      description = "Show attached LSP clients",
      opts = { buffer = bufnr },
    },
    {
      "LspLog",
      function()
        vim.cmd("edit " .. vim.lsp.get_log_path())
      end,
      description = "Show LSP logs",
    },
  }

  if client.name == "null-ls" or client.name == "solargraph" then
    table.insert(commands, {
      "LspFormat",
      function()
        vim.b.format_changedtick = vim.b.changedtick
        vim.lsp.buf.format({ async = true })
      end,
      description = "Format the current document with LSP",
      opts = { buffer = bufnr },
    })
  end

  return commands
end
---------------------------------------------------------------------------- }}}
return M
