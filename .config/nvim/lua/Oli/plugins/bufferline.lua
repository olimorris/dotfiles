local ok, heirline = om.safe_require("heirline")
if not ok then return end

local utils = require("heirline.utils")
local conditions = require("heirline.conditions")

---Trim a filename
---@param filename string
---@param char_limit number
---@param truncate? string
---@return string
local function trim_filename(filename, char_limit, truncate)
  truncate = truncate or " "

  -- Ensure that with the truncation icon, we don't go over the char limit
  if (#filename + #truncate) > char_limit then
    char_limit = char_limit - #truncate
  end

  if #filename > char_limit then filename = string.sub(filename, 1, char_limit) .. truncate end

  return filename
end

---Format a filename
---@param filename string
---@param char_limit? number
---@return string
local function format_filename(filename, char_limit)
  char_limit = char_limit or 18
  local pad = math.ceil((char_limit - #filename) / 2)
  return string.rep(" ", pad) .. trim_filename(filename, char_limit) .. string.rep(" ", pad)
end

local TablineBufnr = {
  provider = function(self) return tostring(self.bufnr) .. ": " end,
  hl = function(self) return { fg = self.is_active and "purple" or "gray", italic = self.is_active } end,
}

local TablineFileName = {
  provider = function(self)
    local filename = self.filename
    filename = filename == "" and "[No Name]" or format_filename(vim.fn.fnamemodify(filename, ":t"))
    return filename
  end,
  hl = function(self)
    return {
      fg = self.is_active and utils.get_highlight("HeirlineBufferline").fg or "gray",
      bg = "bg",
      bold = self.is_active or self.is_visible,
    }
  end,
}

local TablineFileFlags = {
  {
    condition = function(self) return vim.api.nvim_buf_get_option(self.bufnr, "modified") end,
    provider = " ",
    hl = { fg = "red" },
  },
  {
    condition = function(self)
      return not vim.api.nvim_buf_get_option(self.bufnr, "modifiable")
        or vim.api.nvim_buf_get_option(self.bufnr, "readonly")
    end,
    provider = function(self)
      if vim.api.nvim_buf_get_option(self.bufnr, "buftype") == "terminal" then
        return "  "
      else
        return " "
      end
    end,
    hl = { fg = "blue" },
  },
}

local TablineFileNameBlock = {
  init = function(self) self.filename = vim.api.nvim_buf_get_name(self.bufnr) end,
  hl = { bg = "bg" },
  on_click = {
    callback = function(_, minwid, _, button)
      if button == "m" then -- close on mouse middle click
        vim.api.nvim_buf_delete(minwid, { force = false })
      else
        vim.api.nvim_win_set_buf(0, minwid)
      end
    end,
    minwid = function(self) return self.bufnr end,
    name = "heirline_tabline_buffer_callback",
  },
  TablineBufnr,
  TablineFileName,
  TablineFileFlags,
}

local TablineBufferBlock = utils.surround({ " ", " " }, function(self) end, { TablineFileNameBlock })

local BufferLine = utils.make_buflist(
  TablineBufferBlock,
  { provider = " ", hl = { fg = "gray" } },
  { provider = " ", hl = { fg = "gray" } }
)

local BufferLineOffset = {
  condition = function(self)
    local win = vim.api.nvim_tabpage_list_wins(0)[1]
    local bufnr = vim.api.nvim_win_get_buf(win)
    self.winid = win

    if vim.bo[bufnr].filetype == "neo-tree" then
      self.title = "NeoTree"
      return true
    end
  end,

  provider = function(self)
    local title = self.title
    local width = vim.api.nvim_win_get_width(self.winid)
    local pad = math.ceil((width - #title) / 2)
    return string.rep(" ", pad) .. title .. string.rep(" ", pad)
  end,

  hl = function(self)
    if vim.api.nvim_get_current_win() == self.winid then
      return { fg = "purple", bold = true }
    else
      return "Tabline"
    end
  end,
}

local VimLogo = {
  provider = function(self) return "    " end,
  hl = { fg = "vim" },
}

return { BufferLineOffset, VimLogo, BufferLine, require(config_namespace .. ".plugins.tabline") }
