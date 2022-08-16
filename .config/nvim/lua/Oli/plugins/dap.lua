local M = {}

---Show the nice virtual text when debugging
---@return nil|function
local function virtual_text_setup()
  local ok, virtual_text = om.safe_require("nvim-dap-virtual-text")
  if not ok then
    return
  end

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
---@return nil
local function ruby_setup(dap)
  dap.adapters.ruby = function(callback, config)
    callback({
      type = "server",
      host = "127.0.0.1",
      port = "${port}",
      executable = {
        command = "bundle",
        args = { "exec", "rdbg", "--open", "--port", "${port}", "-c", "--", config.command, config.script },
      },
    })
  end

  dap.configurations.ruby = {
    {
      type = "ruby",
      name = "debug current file",
      request = "attach",
      localfs = true,
      command = "ruby",
      script = "${file}",
    },
    {
      type = "ruby",
      name = "run rspec current_file:current_line",
      request = "attach",
      localfs = true,
      command = "rspec",
      script = "${file}",
      current_line = true,
    },
  }
end

---Slick UI which is automatically triggered when debugging
---@return nil
local function ui_setup(dap)
  local ok, dapui = om.safe_require("dapui")
  if not ok then
    return
  end

  dapui.setup()
  dap.listeners.after.event_initialized["dapui_config"] = dapui.open
  dap.listeners.before.event_terminated["dapui_config"] = dapui.close
  dap.listeners.before.event_exited["dapui_config"] = dapui.close
end

---Setup the DAP plugin
---@return nil
function M.setup()
  local ok, dap = om.safe_require("dap")
  if not ok then
    return
  end

  dap.set_log_level("TRACE")

  virtual_text_setup()
  signs_setup()
  ruby_setup(dap)
  ui_setup(dap)
end

return M