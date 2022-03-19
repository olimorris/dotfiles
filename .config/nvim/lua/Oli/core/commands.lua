local M = {}

function M.default_commands()
  return {
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
      function()
        require("persisted").save()
      end,
      description = "Session: Save"
    },
    {
      ":SessionStart",
      function()
        require("persisted").start()
      end,
      description = "Session: Start"
    },
    {
      ":SessionStop",
      function()
        require("persisted").stop()
      end,
      description = "Session: Stop"
    },
    {
      ":SessionDelete",
      function()
        require("persisted").delete()
      end,
      description = "Session: Delete"
    },
    {
      ":Sessions",
      function()
        om.LoadSession()
      end,
      description = "Session: Load"
    },
    {
      ":Reload",
      function()
        om.ReloadConfig()
      end,
      description = "Reload Neovim config"
    },
    {
      ":Rubocop",
      function()
        om.FormatWithRuboCop()
      end,
      description = "Format with Rubocop"
    },
    {
      ":Snippets",
      function()
        om.EditSnippet()
      end,
      description = "Edit Snippets"
    },
    {
      ":TestAll",
      function()
        om.RunTestSuiteAsync()
      end,
      description = "Test all"
    },
    {
      ":Theme",
      function()
        om.ToggleTheme()
      end,
      description = "Toggle theme"
    },
    {
      ":LineNumbers",
      function()
        om.ToggleLineNumbers()
      end,
      description = "Toggle line numbers"
    },
  }
end

function M.plugin_commands()
  return {
    -- Colorizer
    {
      ":ColorizerToggle",
      ":ColorizerToggle",
      description = "Colorizer toggle"
    },
  }
end
return M
