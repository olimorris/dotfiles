----------------------------------NAMESPACE--------------------------------- {{{
_G.om = {
  mappings = {},
}
---------------------------------------------------------------------------- }}}
----------------------------------FUNCTIONS--------------------------------- {{{
---check if a certain feature/version/commit exists in nvim
---@param feature string
---@return boolean
function om.has(feature)
  return vim.fn.has(feature) > 0
end

om.nightly = om.has("nvim-0.8")

---Source a lua or vimscript file
---@param path string path relative to the nvim directory
---@param prefix boolean?
function om.source(path, prefix)
  if not prefix then
    vim.cmd(string.format("source %s", path))
  else
    vim.cmd(string.format("source %s/%s", vim.g.vim_dir, path))
  end
end

---Require a module using [pcall] and report any errors
---@param module string
---@param opts table?
---@return boolean, any
function om.safe_require(module, opts)
  opts = opts or { silent = false }
  local ok, result = pcall(require, module)
  if not ok and not opts.silent then
    vim.notify(result, vim.log.levels.ERROR, { title = string.format("Error requiring: %s", module) })
  end
  return ok, result
end

---Determine if a table contains a value
---@param tbl table
---@param value string
---@return boolean
function om.contains(tbl, value)
  return tbl[value] ~= nil
end

---Pretty print a table
---@param tbl table
---@return string
function om.print_table(tbl)
  require("pl.pretty").dump(tbl)
end

---Reload lua modules
---@param path string
---@param recursive string
function om.reload(path, recursive)
  if recursive then
    for key, value in pairs(package.loaded) do
      if key ~= "_G" and value and vim.fn.match(key, path) ~= -1 then
        if string.match(key, "legendary") ~= "legendary" then
          package.loaded[key] = nil
          require(key)
        end
      end
    end
  else
    package.loaded[path] = nil
    require(path)
  end
end

---Use Neovim native UI select
---@param prompt string
---@param choices table
---@param callback function
---@return function
function om.select(prompt, choices, callback)
  vim.ui.select(choices, { prompt = prompt }, callback)
end

function om.get_icon(filename, extension, opts)
  local ok, devicons = om.safe_require("nvim-web-devicons")
  if not ok then
    vim.notify("nvim-web-devicons not installed")
  end

  local icon_str, icon_color = devicons.get_icon_color(filename, extension, { default = true })

  local icon = { str = icon_str }

  if opts.colored_icon ~= false then
    icon.hl = { fg = icon_color }
  end

  return icon
end

---Return true if any pattern in the tbl matches the provided value
---@param tbl table
---@param val string
---@return boolean
function om.find_pattern_match(tbl, val)
  return tbl and next(vim.tbl_filter(function(pattern)
    return val:match(pattern)
  end, tbl))
end

---Run a process asynchronously
---@param process table (command, args, callback)
---@return nil
--- Inspiration from: https://phelipetls.github.io/posts/async-make-in-nvim-with-lua/
function om.async_run(process)
  if not process.command then
    return
  end

  local lines = { "OUTPUT:" }
  local winnr = vim.fn.win_getid()
  local bufnr = vim.api.nvim_win_get_buf(winnr)

  -- Run the before callback prior to executing the process
  local function cmd_to_execute()
    local cmd = process.command

    -- Join any arguments to the end of the command
    if process.args then
      cmd = cmd .. " " .. process.args
    end

    -- Execute the BEFORE callback before starting the job
    if process.callbacks and process.callbacks.before then
      process.callbacks.before()
    end

    vim.g.async_status = "running"

    return cmd
  end

  local function on_event(_, data, event)
    if event == "stdout" or event == "stderr" then
      if data then
        vim.list_extend(lines, data)
      end
    end

    local ok, efm = pcall(vim.api.nvim_buf_get_option, bufnr, "errorformat")
    efm = not ok and vim.o.errorformat or efm

    if event == "exit" then
      -- Popupulate the QF window on a completed run
      -- vim.fn.setqflist({}, " ", { title = "Command Output", lines = lines, efm = efm })
      vim.fn.setqflist({}, " ", { title = "Command Output", lines = lines })

      if data == 0 then
        vim.g.async_status = "success"
      else
        vim.g.async_status = "fail"
      end

      -- Execute the AFTER callback now the job has completed
      if process.callbacks and process.callbacks.after then
        process.callbacks.after()
      end

      -- As we're populating the QF window, send the autocommand
      vim.api.nvim_command("doautocmd QuickFixCmdPost")

      -- Clear the async_status after a period of time
      local i = 0
      local max = 50
      local timer = vim.loop.new_timer()
      timer:start(
        0,
        max,
        vim.schedule_wrap(function()
          i = i + 1
          if i >= max then
            vim.g.async_status = nil
            timer:stop()
            return
          end
        end)
      )
    end
  end

  -- Execute the job
  local id = vim.fn.jobstart(cmd_to_execute(), {
    on_stderr = on_event,
    on_stdout = on_event,
    on_exit = on_event,
    stdout_buffered = true,
    stderr_buffered = true,
  })
end
---------------------------------------------------------------------------- }}}
