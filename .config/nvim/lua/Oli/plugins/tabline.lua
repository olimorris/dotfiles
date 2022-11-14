local ok, heirline = om.safe_require("heirline")
if not ok then return end

local utils = require("heirline.utils")
local conditions = require("heirline.conditions")

local Tabpage = {
  provider = function(self) return "%" .. self.tabnr .. "T " .. self.tabnr .. " %T" end,
  hl = function(self)
    if not self.is_active then
      return "TabLine"
    else
      return "TabLineSel"
    end
  end,
}

local TabpageClose = {
  provider = "%999X  %X",
  hl = { fg = "gray" },
}

local TabPages = {
  -- only show this component if there's 2 or more tabpages
  condition = function() return #vim.api.nvim_list_tabpages() >= 2 end,
  { provider = "%=" },
  utils.make_tablist(Tabpage),
  TabpageClose,
}

return TabPages
