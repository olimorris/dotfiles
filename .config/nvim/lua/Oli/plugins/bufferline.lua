local ok, heirline = om.safe_require("heirline")
if not ok then return end

local utils = require("heirline.utils")
local conditions = require("heirline.conditions")

local TablineBufnr = {
  provider = function(self) return tostring(self.bufnr) .. ": " end,
  hl = function(self) return { fg = self.is_active and "purple" or "gray", italic = self.is_active } end,
}

-- we redefine the filename component, as we probably only want the tail and not the relative path
local TablineFileName = {
  provider = function(self)
    -- self.filename will be defined later, just keep looking at the example!
    local filename = self.filename
    filename = filename == "" and "[No Name]" or vim.fn.fnamemodify(filename, ":t")
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

-- this looks exactly like the FileFlags component that we saw in
-- #crash-course-part-ii-filename-and-friends, but we are indexing the bufnr explicitly
-- also, we are adding a nice icon for terminal buffers.
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

-- Here the filename block finally comes together
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

-- The final touch!
local TablineBufferBlock = utils.surround({ "  ", "   " }, function(self) end, { TablineFileNameBlock })

-- and here we go
local BufferLine = utils.make_buflist(
  TablineBufferBlock,
  { provider = "", hl = { fg = "gray" } }, -- left truncation, optional (defaults to "<")
  { provider = "", hl = { fg = "gray" } } -- right trunctation, also optional (defaults to ...... yep, ">")
  -- by the way, open a lot of buffers and try clicking them ;)
)
return BufferLine
