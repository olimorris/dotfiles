local M = {}

function M.default_commands()
  return {
    {
      ":Uuid",
      function()
        local uuid = vim.fn.system("uuidgen"):gsub("\n", ""):lower()
        local line = vim.fn.getline(".")
        vim.schedule(function()
          vim.fn.setline(".", vim.fn.strpart(line, 0, vim.fn.col(".")) .. uuid .. vim.fn.strpart(line, vim.fn.col(".")))
        end)
      end,
      description = "Generate a UUID and insert it into the buffer",
    },
    {
      ":Sessions",
      function()
        om.LoadSession()
      end,
      description = "Session: Load",
    },
    {
      ":Reload",
      function()
        om.ReloadConfig()
      end,
      description = "Reload Neovim config",
    },
    {
      ":Rubocop",
      function()
        om.FormatWithRuboCop()
      end,
      description = "Format with Rubocop",
    },
    {
      ":Snippets",
      function()
        om.EditSnippet()
      end,
      description = "Edit Snippets",
    },
    {
      ":TestAll",
      function()
        om.RunTestSuiteAsync()
      end,
      description = "Test all",
    },
    {
      ":Theme",
      function()
        om.ToggleTheme()
      end,
      description = "Toggle theme",
    },
    {
      ":LineNumbers",
      function()
        om.ToggleLineNumbers()
      end,
      description = "Toggle line numbers",
    },
  }
end

function M.plugin_commands()
  return {
    -- Colorizer
    {
      ":ColorizerToggle",
      description = "Colorizer toggle",
    },
    -- LSP
    {
      ":LspLog",
      function()
        vim.cmd("edit " .. vim.lsp.get_log_path())
      end,
      description = "Show LSP logs",
    },
    {
      ":LspInstall",
      function()
        for _, name in pairs(om.lsp.servers) do
          vim.cmd("LspInstall " .. name)
        end
      end,
      description = "Install LSP servers",
    },
    {
      ":LspUninstall",
      function()
        vim.cmd("LspUninstallAll")
      end,
      description = "Uninstall LSP servers",
    },
    -- Packer
    {
      ":PC",
      function()
        require(config_namespace .. ".core.plugins")
        require("packer").compile()
      end,
      description = "Packer: Compile",
    },
    {
      ":PCL",
      function()
        require(config_namespace .. ".core.plugins")
        require("packer").clean()
      end,
      description = "Packer: Clean",
    },
    {
      ":PI",
      function()
        require(config_namespace .. ".core.plugins")
        require("packer").install()
      end,
      description = "Packer: Install",
    },
    {
      ":PS",
      function()
        require(config_namespace .. ".core.plugins")
        require("packer").sync()
      end,
      description = "Packer: Sync",
    },
    {
      ":PST",
      function()
        require(config_namespace .. ".core.plugins")
        require("packer").status()
      end,
      description = "Packer: Status",
    },
    {
      ":PU",
      function()
        require(config_namespace .. ".core.plugins")
        require("packer").update()
      end,
      description = "Packer: Update",
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
  }
end

function M.lsp_commands(client, bufnr)
  local commands = {
    {
      ":LspRestart",
      description = "Restart any attached LSP clients",
      opts = { buffer = bufnr },
    },
    {
      ":LspStart",
      description = "Start the LSP client manually",
      opts = { buffer = bufnr },
    },
    {
      ":LspInfo",
      description = "Show attached LSP clients",
      opts = { buffer = bufnr },
    },
  }

  if client.name == "null-ls" or client.name == "solargraph" then
    table.insert(commands, {
      ":LspFormat",
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

return M
