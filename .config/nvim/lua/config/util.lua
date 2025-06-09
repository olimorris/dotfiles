local api = vim.api

-- Set the global namespace
_G.om = {}

---Check if a certain feature/version/commit exists in nvim
---@param feature string
---@return boolean
function om.has(feature)
  return vim.fn.has(feature) > 0
end

om.nightly = om.has("nvim-0.12")
om.on_personal = vim.fn.getenv("USER") == "Oli"

---Determine if you're on an external monitor
---@return boolean
function om.on_big_screen()
  return vim.o.columns > 150 and vim.o.lines >= 40
end

---Set a keymap in Neovim
---@param lhs string The left-hand side of the keymap (the key combination)
---@param rhs string|function The right-hand side of the keymap (the command to execute)
---@param mode string The mode in which the keymap should be set (e.g., "n" for normal mode)
---@param opts? table Optional parameters for the keymap, such as silent or noremap
---@return nil
function om.set_keymaps(lhs, rhs, mode, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

---Create a user command in Neovim
---@param name string The name of the command
---@param desc string A description of the command
---@param command string|function The command to execute, can be a string or a function
---@param opts table Optional parameters for the command, such as nargs
---@return nil
function om.create_user_command(name, desc, command, opts)
  api.nvim_create_user_command(name, command, {
    desc = desc,
    nargs = opts and opts.nargs or 0,
  })
end

---Create an autocommand in Neovim
---@param autocmd string|table The autocmd event(s) to trigger the command
---@param opts {group: string, buffer: number, pattern: string, callback: function|string} Optional parameters for the autocmd
---@return nil
function om.create_autocmd(autocmd, opts)
  opts = opts or {}

  -- Pattern takes precedence over buffer
  if opts.pattern and opts.buffer then
    opts.buffer = nil
  end

  api.nvim_create_autocmd(autocmd, {
    group = opts.group,
    buffer = opts.buffer,
    pattern = opts.pattern,
    callback = type(opts.callback) == "function" and opts.callback or function()
      vim.cmd(opts.callback)
    end,
  })
end
