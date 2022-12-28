local M = {
  "mfussenegger/nvim-dap", -- Debug Adapter Protocol for Neovim
  lazy = true,
  dependencies = {
    "theHamsta/nvim-dap-virtual-text", -- help to find variable definitions in debug mode
    "rcarriga/nvim-dap-ui", -- Nice UI for nvim-dap
  },
}

function M.config()
  local dap = require("dap")

  ---Show the nice virtual text when debugging
  ---@return nil|function
  local function virtual_text_setup()
    local ok, virtual_text = om.safe_require("nvim-dap-virtual-text")
    if not ok then return end

    return virtual_text.setup()
  end

  ---Show custom virtual text when debugging
  ---@return nil
  local function signs_setup()
    vim.fn.sign_define("DapBreakpoint", {
      text = "",
      texthl = "DebugBreakpoint",
      linehl = "",
      numhl = "DebugBreakpoint",
    })
    vim.fn.sign_define("DapStopped", {
      text = "",
      texthl = "DebugHighlight",
      linehl = "",
      numhl = "DebugHighlight",
    })
  end

  ---Custom Ruby debugging config
  ---@param dap table
  ---@return nil
  local function ruby_setup(dap)
    dap.adapters.ruby = function(callback, config)
      local script

      if config.current_line then
        script = config.script .. ":" .. vim.fn.line(".")
      else
        script = config.script
      end

      callback({
        type = "server",
        host = "127.0.0.1",
        port = "${port}",
        executable = {
          command = "bundle",
          args = { "exec", "rdbg", "--open", "--port", "${port}", "-c", "--", config.command, script },
        },
      })
    end

    dap.configurations.ruby = {
      {
        type = "ruby",
        name = "debug rspec current_line",
        request = "attach",
        localfs = true,
        command = "rspec",
        script = "${file}",
        current_line = true,
      },
      {
        type = "ruby",
        name = "debug current file",
        request = "attach",
        localfs = true,
        command = "ruby",
        script = "${file}",
      },
    }
  end

  ---Slick UI which is automatically triggered when debugging
  ---@param dap table
  ---@return nil
  local function ui_setup(dap)
    local ok, dapui = om.safe_require("dapui")
    if not ok then return end

    dapui.setup({
      layouts = {
        {
          elements = {
            "scopes",
            "breakpoints",
            "stacks",
          },
          size = 35,
          position = "left",
        },
        {
          elements = {
            "repl",
          },
          size = 0.30,
          position = "bottom",
        },
      },
    })
    dap.listeners.after.event_initialized["dapui_config"] = dapui.open
    dap.listeners.before.event_terminated["dapui_config"] = dapui.close
    dap.listeners.before.event_exited["dapui_config"] = dapui.close
  end

  dap.set_log_level("TRACE")

  virtual_text_setup()
  signs_setup()
  ruby_setup(dap)
  ui_setup(dap)

  require("legendary").keymaps({
    {
      itemgroup = "Debug",
      description = "Debugging functionality",
      icon = "",
      keymaps = {
        {
          "<F1>",
          "<cmd>lua require('dap').toggle_breakpoint()<CR>",
          description = "Set breakpoint",
        },
        { "<F2>", "<cmd>lua require('dap').continue()<CR>", description = "Continue" },
        { "<F3>", "<cmd>lua require('dap').step_into()<CR>", description = "Step into" },
        { "<F4>", "<cmd>lua require('dap').step_over()<CR>", description = "Step over" },
        {
          "<F5>",
          "<cmd>lua require('dap').repl.toggle({height = 6})<CR>",
          description = "Toggle REPL",
        },
        { "<F6>", "<cmd>lua require('dap').repl.run_last()<CR>", description = "Run last" },
        {
          "<F9>",
          function()
            local _, dap = om.safe_require("dap")
            dap.disconnect()
            require("dapui").close()
          end,
          description = "Stop",
        },
      },
    },
  })
end

return M
