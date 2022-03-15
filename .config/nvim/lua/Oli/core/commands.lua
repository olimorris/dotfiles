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
      description = "Packer: Status",
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
      ":SessionLoad",
      function()
        require("persisted").load()
      end,
      description = "Session: Load"
    },
    {
      ":SessionDelete",
      function()
        require("persisted").delete()
      end,
      description = "Session: Delete"
    },
    --
  }
end

return M
