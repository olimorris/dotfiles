local api, fn = vim.api, vim.fn

om.winbar = {}

local ignored_buftypes = { "nofile", "prompt", "help", "quickfix", "terminal" }
local ignored_filetypes = { "alpha", "oil", "codecompanion", "lspinfo", "snacks_dashboard", "toggleterm" }

---Path prefixes collapsed to something friendlier to read
local shorten = table.concat({
  ":s?" .. om.home .. "/.dotfiles?dotfiles?",
  ":s?.config/nvim/lua?Neovim?",
  ":s?" .. om.home .. "/Code?Code?",
})

local SEP = " 󰅂 "

---A literal `%` would be read as the start of a |statusline| item
---@param str string
---@return string
local function escape(str)
  return (str:gsub("%%", "%%%%"))
end

-- Sections -------------------------------------------------------------------

local section = {
  ---@return string
  icon = function()
    local name = api.nvim_buf_get_name(0)
    local icon, hl = require("nvim-web-devicons").get_icon(name, fn.fnamemodify(name, ":e"), { default = true })

    return icon and ("%#" .. hl .. "#" .. icon .. " ") or ""
  end,

  ---@return string
  filename = function()
    local path = fn.fnamemodify(fn.fnamemodify(api.nvim_buf_get_name(0), ":."), shorten)
    if path == "" then
      return "%#WinbarFile#[No Name]"
    end

    -- Trim the path to its initials rather than let it swallow the window
    if #path > api.nvim_win_get_width(0) * 0.9 then
      path = fn.pathshorten(path)
    end

    local dir, file = path:match("^(.*/)([^/]+)$")
    return "%#WinbarPath#" .. escape(dir or "") .. "%#WinbarFile#" .. escape(file or path)
  end,

  ---@return string
  flags = function()
    local out = ""
    if vim.bo.modified then
      out = out .. "%#WinbarModified# "
    end
    if vim.bo.readonly or not vim.bo.modifiable then
      out = out .. "%#WinbarReadonly# "
    end

    return out
  end,

  ---@return string
  symbols = function()
    if not package.loaded.aerial then
      return ""
    end

    local symbols = require("aerial").get_location(true)
    if not symbols or vim.tbl_isempty(symbols) then
      return ""
    end

    local out = {}
    for _, symbol in ipairs(symbols) do
      -- Aerial's icons carry their own trailing space
      local hl = "Aerial" .. symbol.kind .. "Icon"
      out[#out + 1] = (fn.hlexists(hl) == 1 and "%#" .. hl .. "#" or "")
        .. symbol.icon
        .. "%#WinbarSymbol#"
        .. escape((symbol.name:gsub("%s*->%s*", "")))
    end

    return "%#WinbarSymbol#" .. SEP .. table.concat(out, SEP)
  end,

  ---@return string
  logo = function()
    return "%#VimLogo# "
  end,
}
om.winbar.section = section

-- Content --------------------------------------------------------------------

---@return string
function om.winbar.content()
  return " " .. section.icon() .. section.filename() .. section.flags() .. section.symbols() .. "%*%=" .. section.logo()
end

-- Setup ----------------------------------------------------------------------

local WINBAR = "%{%v:lua.om.winbar.content()%}"

---@param buf number
---@return boolean
local function ignored(buf)
  return vim.tbl_contains(ignored_buftypes, vim.bo[buf].buftype)
    or vim.tbl_contains(ignored_filetypes, vim.bo[buf].filetype)
end

api.nvim_create_autocmd({ "BufWinEnter", "BufFilePost", "FileType", "TermOpen", "WinEnter", "OptionSet" }, {
  group = api.nvim_create_augroup("Winbar", { clear = true }),
  pattern = { "*", "buftype" },
  callback = function()
    local buf = api.nvim_get_current_buf()
    if api.nvim_win_get_buf(0) ~= buf or api.nvim_win_get_config(0).relative ~= "" then
      return
    end
    vim.wo.winbar = ignored(buf) and "" or WINBAR
  end,
})
