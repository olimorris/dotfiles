-- Set the global namespace
_G.om = {}

---Check if a certain feature/version/commit exists in nvim
---@param feature string
---@return boolean
function om.has(feature)
  return vim.fn.has(feature) > 0
end

om.nightly = om.has("nvim-0.11")
om.on_personal = vim.fn.getenv("USER") == "Oli"

---Determine if you're on an external monitor
---@return boolean
function om.on_big_screen()
  return vim.o.columns > 150 and vim.o.lines >= 40
end

---Create a user command in Neovim
---@param name string The name of the command
---@param command string|function The command to execute, can be a string or a function
---@param desc string A description of the command
---@param opts table Optional parameters for the command, such as nargs
---@return nil
function om.create_user_command(name, command, desc, opts)
  vim.api.nvim_create_user_command(name, command, {
    desc = desc,
    nargs = opts and opts.nargs or 0,
  })
end
