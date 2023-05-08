-- Set the global namespace
_G.om = {}

---check if a certain feature/version/commit exists in nvim
---@param feature string
---@return boolean
function om.has(feature) return vim.fn.has(feature) > 0 end

om.nightly = om.has("nvim-0.10")

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
function om.contains(tbl, value) return tbl[value] ~= nil end

---Pretty print a table
---@param tbl table
---@return table
function om.print_table(tbl) return require("pl.pretty").dump(tbl) end

---Get values for a given highlight group
---@param name string
---@return table
function om.get_highlight(name)
  local hl = vim.api.nvim_get_hl_by_name(name, vim.o.termguicolors)
  if vim.o.termguicolors then
    hl.fg = hl.foreground
    hl.bg = hl.background
    hl.sp = hl.special
    hl.foreground = nil
    hl.background = nil
    hl.special = nil
  else
    hl.ctermfg = hl.foreground
    hl.ctermbg = hl.background
    hl.foreground = nil
    hl.background = nil
    hl.special = nil
  end
  return hl
end

---Invalidate lua modules
---@param path string
---@param recursive boolean
function om.invalidate(path, recursive)
  if recursive then
    for key, value in pairs(package.loaded) do
      if key ~= "_G" and value and vim.fn.match(key, path) ~= -1 then
        package.loaded[key] = nil
        require(key)
      end
    end
  else
    package.loaded[path] = nil
    require(path)
  end
end

---Return true if any pattern in the tbl matches the provided value
---@param tbl table
---@param val string
---@return boolean
function om.find_pattern_match(tbl, val)
  return tbl and next(vim.tbl_filter(function(pattern) return val:match(pattern) end, tbl))
end
