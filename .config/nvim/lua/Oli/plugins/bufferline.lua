local ok, heirline = om.safe_require("heirline")
if not ok then return end

local utils = require("heirline.utils")
local conditions = require("heirline.conditions")

local function trim_filename(filename, char_limit, truncate)
  local length = string.len(filename)
  truncate = truncate or " ..."

  if length > char_limit then filename = string.sub(filename, 1, char_limit) .. truncate end

  return filename
end

local function format_filename(filename, char_limit)
  if string.len(filename) >= char_limit then return trim_filename(filename, char_limit, "") end

  local diff = char_limit - string.len(filename)

  -- If divisible by 2, add spaces to both sides
  if (diff % 2) == 0 then return string.rep(" ", diff / 2) .. filename .. string.rep(" ", diff / 2) end

  -- If not, add uneven space to both sides
  return string.rep(" ", diff / 2) .. filename .. string.rep(" ", diff / 2) .. " "
end

local TablineBufnr = {
  provider = function(self) return tostring(self.bufnr) .. ": " end,
  hl = function(self) return { fg = self.is_active and "purple" or "gray", italic = self.is_active } end,
}

local TablineFileName = {
  provider = function(self)
    -- self.filename will be defined later, just keep looking at the example!
    local filename = self.filename
    filename = filename == "" and "[No Name]" or format_filename(vim.fn.fnamemodify(filename, ":t"), 15)
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
return BufferLine
