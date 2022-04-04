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
      "Sessions",
      function()
        om.LoadSession()
      end,
      description = "Session: Load",
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
      description = "Show the Alpha dashboard"
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
    -- GPS
    {
      "NvimGPS",
      function()
        if vim.g.enable_gps then
          vim.g.enable_gps = false
        else
          vim.g.enable_gps = true
        end
      end,
      description = "Toggle Nvim GPS",
    },
    -- Lazygit
    {
      "Lazygit",
      function()
        om.Lazygit():toggle()
      end,
      description = "Lazygit",
    },
    -- neogen
    {
      "Neogen",
      function()
        require("neogen").generate()
      end,
      description = "Generate annotation",
    },
    -- Packer
    {
      "PackerCompile",
      function()
        vim.g.packer_reloaded = true
        require(config_namespace .. ".plugins")
        require("packer").compile()
      end,
      description = "Packer: Compile",
    },
    {
      "PackerClean",
      function()
        require(config_namespace .. ".plugins")
        require("packer").clean()
      end,
      description = "Packer: Clean",
    },
    {
      "PackerInstall",
      function()
        require(config_namespace .. ".plugins")
        require("packer").install()
      end,
      description = "Packer: Install",
    },
    {
      "PackerSync",
      function()
        require(config_namespace .. ".plugins")
        require("packer").sync()
      end,
      description = "Packer: Sync",
    },
    {
      "PackerStatus",
      function()
        require(config_namespace .. ".plugins")
        require("packer").status()
      end,
      description = "Packer: Status",
    },
    {
      "PackerUpdate",
      function()
        require(config_namespace .. ".plugins")
        require("packer").update()
      end,
      description = "Packer: Update",
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
    {
      "LspInstall",
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
  }

  if client.name == "null-ls" or client.name == "solargraph" then
    table.insert(commands, {
      "LspFormat",
      function()
        vim.b.format_changedtick = vim.b.changedtick
        vim.lsp.buf.formatting({})
      end,
      description = "Format the current document with LSP",
      opts = { buffer = bufnr },
    })
  end

  return commands
end
---------------------------------------------------------------------------- }}}
return M
