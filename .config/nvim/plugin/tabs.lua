local api, fn = vim.api, vim.fn

om.tabline = {}

local CLOSE = ""
local MODIFIED = " "

---@param str string
---@return string
local function escape(str)
  -- A literal `%` would be read as the start of a |statusline| item
  return (str:gsub("%%", "%%%%"))
end

---@param tab number Tabpage handle
---@return number
local function tab_buf(tab)
  return api.nvim_win_get_buf(api.nvim_tabpage_get_win(tab))
end

---@param buf number
---@return string
local function label(buf)
  local name = api.nvim_buf_get_name(buf)
  if name == "" then
    return vim.bo[buf].buftype == "" and "[No Name]" or "[Scratch]"
  end

  return escape(fn.fnamemodify(name, ":t"))
end

---@return string
function om.tabline.content()
  local current = api.nvim_get_current_tabpage()
  local out = {}

  for i, tab in ipairs(api.nvim_list_tabpages()) do
    local selected = tab == current
    local hl = selected and "%#TabLineSel#" or "%#TabLine#"
    local buf = tab_buf(tab)

    out[#out + 1] = table.concat({
      "%" .. i .. "T",
      hl .. " " .. label(buf),
      vim.bo[buf].modified and ("%#TablineModified# " .. MODIFIED) or "",
      hl .. " ",
    })
  end

  -- %T closes the last tab's click region, otherwise the empty right-hand side
  -- of the bar selects that tab when clicked
  return table.concat(out) .. "%T%#TabLineFill#%=%999X%#TablineClose# " .. CLOSE .. " %X"
end

vim.o.tabline = "%{%v:lua.om.tabline.content()%}"
