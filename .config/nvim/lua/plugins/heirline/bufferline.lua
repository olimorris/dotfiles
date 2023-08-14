local M = {}

local utils = require("heirline.utils")
table.unpack = table.unpack or unpack -- 5.1 compatibility

---Get the names of all current listed buffers
---@return table
local function get_current_filenames()
  local listed_buffers = vim.tbl_filter(
    function(bufnr) return vim.bo[bufnr].buflisted and vim.api.nvim_buf_is_loaded(bufnr) end,
    vim.api.nvim_list_bufs()
  )

  return vim.tbl_map(vim.api.nvim_buf_get_name, listed_buffers)
end

---Get unique name for the current buffer
---@param filename string
---@param shorten boolean
---@return string
local function get_unique_filename(filename, shorten)
  local filenames = vim.tbl_filter(
    function(filename_other) return filename_other ~= filename end,
    get_current_filenames()
  )

  if shorten then
    filename = vim.fn.pathshorten(filename)
    filenames = vim.tbl_map(vim.fn.pathshorten, filenames)
  end

  -- Reverse filenames in order to compare their names
  filename = string.reverse(filename)
  filenames = vim.tbl_map(string.reverse, filenames)

  local index

  -- For every other filename, compare it with the name of the current file char-by-char to
  -- find the minimum index `i` where the i-th character is different for the two filenames
  -- After doing it for every filename, get the maximum value of `i`
  if next(filenames) then
    index = math.max(table.unpack(vim.tbl_map(function(filename_other)
      for i = 1, #filename do
        -- Compare i-th character of both names until they aren't equal
        if filename:sub(i, i) ~= filename_other:sub(i, i) then return i end
      end
      return 1
    end, filenames)))
  else
    index = 1
  end

  -- Iterate backwards (since filename is reversed) until a "/" is found
  -- in order to show a valid file path
  while index <= #filename do
    if filename:sub(index, index) == "/" then
      index = index - 1
      break
    end

    index = index + 1
  end

  return string.reverse(string.sub(filename, 1, index))
end

---Trim a filename
---@param filename string
---@param char_limit number
---@param truncate? string
---@return string
local function trim_filename(filename, char_limit, truncate)
  truncate = truncate or " "

  -- Ensure that with the truncation icon, we don't go over the char limit
  if (#filename + #truncate) > char_limit then char_limit = char_limit - #truncate end

  if #filename > char_limit then filename = string.sub(filename, 1, char_limit) .. truncate end

  return filename
end

---Format a filename
---@param filename string
---@param char_limit? number
---@return string
local function format_filename(filename, char_limit)
  filename = get_unique_filename(filename, false)

  char_limit = char_limit or 18
  local pad = math.ceil((char_limit - #filename) / 2)
  return string.rep(" ", pad) .. trim_filename(filename, char_limit) .. string.rep(" ", pad)
end

-- Navigate to buffers with keystrokes
local TablinePicker = {
  condition = function(self) return self._show_picker end,
  init = function(self)
    local bufname = vim.api.nvim_buf_get_name(self.bufnr)
    bufname = vim.fn.fnamemodify(bufname, ":t")
    local label = bufname:sub(1, 1)
    local i = 2
    while self._picker_labels[label] do
      if i > #bufname then break end
      label = bufname:sub(i, i)
      i = i + 1
    end
    self._picker_labels[label] = self.bufnr
    self.label = label
  end,
  provider = function(self) return self.label .. ": " end,
  hl = { fg = "red", bold = true, italic = true },
}

local TablineBufnr = {
  condition = function(self) return not self._show_picker end,
  provider = function(self) return tostring(self.bufnr) .. ": " end,
  hl = function(self) return { fg = self.is_active and "purple" or "gray", italic = true } end,
}

local TablineFileName = {
  provider = function(self)
    local filename = self.filename
    filename = filename == "" and "[No Name]" or format_filename(vim.fn.fnamemodify(filename, ":t:r"), 15)
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
  TablinePicker,
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
    elseif vim.bo[bufnr].filetype == "aerial" then
      self.title = "Aerial"
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
  hl = "BufferlineVim",
}

return { BufferLineOffset, VimLogo, BufferLine, require("plugins.heirline.tabline") }
