--[[
===============================================================================
    File:       diagnostics.lua
    Author:     Oli Morris
-------------------------------------------------------------------------------
    Description:
      Show diagnostic summary as virtual text in the buffer
      Modified from the excellent:
        https://github.com/ivanjermakov/troublesum.nvim
===============================================================================
--]]

local M = {}

local ns_id = nil
local config = {}

---Get diagnostic counts for the current buffer
---@return number[]
local function get_counts()
  local counts = { 0, 0, 0, 0 }
  for _, d in ipairs(vim.diagnostic.get(0)) do
    counts[d.severity] = counts[d.severity] + 1
  end
  return counts
end

---Display diagnostic summary
---@return nil
local function display()
  if not ns_id then
    ns_id = vim.api.nvim_create_namespace("dotfiles.diagnostics")
  end

  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)

  local virt_text = {}
  for severity, count in ipairs(get_counts()) do
    if count > 0 then
      if #virt_text > 0 then
        table.insert(virt_text, { " ", "Normal" })
      end
      table.insert(virt_text, {
        string.format("%s %d", config.severity_format[severity], count),
        config.severity_highlight[severity],
      })
    end
  end

  if #virt_text == 0 then
    return
  end

  vim.api.nvim_buf_set_extmark(0, ns_id, vim.fn.line("w0") - 1, 0, {
    virt_text = virt_text,
    virt_text_pos = "right_align",
  })
end

---Check if should display for current buffer
---@return boolean
local function is_enabled()
  if type(config.enabled) == "function" then
    return config.enabled()
  end
  return config.enabled
end

---Setup diagnostic summary
---@param opts? { enabled?: boolean|function, severity_format?: string[], severity_highlight?: string[] }
---@return nil
function M.setup(opts)
  config = vim.tbl_deep_extend("force", {
    enabled = true,
    severity_format = { "E", "W", "I", "H" },
    severity_highlight = {
      "DiagnosticError",
      "DiagnosticWarn",
      "DiagnosticInfo",
      "DiagnosticHint",
    },
  }, opts or {})

  if not is_enabled() then
    return
  end

  vim.api.nvim_create_autocmd({ "DiagnosticChanged", "WinScrolled", "WinResized" }, {
    group = vim.api.nvim_create_augroup("dotfiles.diagnostics", { clear = true }),
    callback = function()
      if is_enabled() then
        display()
      end
    end,
  })
end

return M
