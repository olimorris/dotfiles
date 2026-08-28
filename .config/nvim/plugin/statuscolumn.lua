local MiniStatuscolumn = require("mini.statuscolumn")

local api, fn, v = vim.api, vim.fn, vim.v

om.statuscolumn = { click = {} }
local click = om.statuscolumn.click

local ignored_buftypes = { "prompt", "help", "quickfix", "terminal" }
local ignored_filetypes = { "lspinfo", "snacks_dashboard", "toggleterm" }

local git_ns = api.nvim_create_namespace("gitsigns_signs_")

---The highest priority sign on a line, ignoring gitsigns
---@param lnum number
---@return table|nil Extmark details
local function sign_at(lnum)
  local extmarks = api.nvim_buf_get_extmarks(
    0,
    -1,
    { lnum - 1, 0 },
    { lnum - 1, -1 },
    { details = true, type = "sign" }
  )

  local out
  for _, extmark in ipairs(extmarks) do
    local sign = extmark[4]
    if sign.ns_id ~= git_ns and sign.sign_text and (out == nil or (sign.priority or 0) > (out.priority or 0)) then
      out = sign
    end
  end

  return out
end

-- Sections -------------------------------------------------------------------

local section = {
  ---@return string
  sign = function()
    local sign = sign_at(v.lnum)
    if not sign then
      return "%#SignColumn#  "
    end

    local text = sign.sign_text:gsub("%%", "%%%%")
    return "%#" .. (sign.sign_hl_group or "SignColumn") .. "#" .. text
  end,

  ---@return string
  git = function()
    local extmark =
      api.nvim_buf_get_extmarks(0, git_ns, { v.lnum - 1, 0 }, { v.lnum - 1, -1 }, { limit = 1, details = true })[1]

    local hl = extmark and extmark[4].sign_hl_group
    return hl and ("%#" .. hl .. "#│") or " "
  end,
}
om.statuscolumn.section = section

-- Click handlers -------------------------------------------------------------

local click_handlers = {
  sep = function()
    vim.defer_fn(function()
      require("snacks").git.blame_line()
    end, 100)
  end,
}

---Make the clicked line current
---@param data table See |MiniStatuscolumn.gen_content.main()|
local function on_click(data)
  local pos = data.mousepos
  if not pcall(api.nvim_set_current_win, pos.winid) then
    return
  end
  pcall(api.nvim_win_set_cursor, pos.winid, { pos.line, 0 })

  local handler = click_handlers[data.section]
  if handler then
    handler(pos)
  end
end

-- Content --------------------------------------------------------------------

---@param buf number|nil
---@return boolean
local function ignored(buf)
  if buf == nil or not api.nvim_buf_is_valid(buf) then
    return true
  end
  return vim.tbl_contains(ignored_buftypes, vim.bo[buf].buftype)
    or vim.tbl_contains(ignored_filetypes, vim.bo[buf].filetype)
end

local content = MiniStatuscolumn.gen_content.main({
  {
    format = "s=lf",
    lnum = "%l ",
    sign = "%{%v:lua.om.statuscolumn.section.sign()%}",
    sep = "%{%v:lua.om.statuscolumn.section.git()%}",
  },
  { ltype = "virt", lnum = "", sign = "  " },
  { ltype = "wrap", lnum = "", sign = "  " },
  { pos = "cursor", ltype = "text", lnum = "%#CursorLineNr#%{&nu ? v:lnum : ''} " },
}, { click = on_click })

---Blank the column in buffers which have no use for it
---@param f function
---@return function
local function guard(f)
  return function(data)
    return ignored(data.buf_id) and "" or f(data)
  end
end

-- Setup ----------------------------------------------------------------------
MiniStatuscolumn.setup({
  content = { active = guard(content.active), inactive = guard(content.inactive) },
  dim_inactive = false,
})
