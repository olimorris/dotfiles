local M = {}

local sep = "  "
local LeftSlantEnd = {
  provider = "",
  hl = { fg = "statusline_bg", bg = "bg" },
}

local modifiers = {
  dirname = ":.:s?/Users/Oli/.dotfiles?dotfiles?:s?.config/nvim/lua/Oli?Neovim?:s?/Users/Oli/Code?Code?",
}

M.vim_logo = {
  provider = " ",
  hl = "VimLogo",
}

M.cwd = {
  init = function(self) self.cwd = vim.fn.fnamemodify(vim.loop.cwd(), modifiers.dirname or nil) end,
  {
    condition = function(self) return true end,
    provider = function(self)
      local trim = 30
      local output = table.concat(vim.fn.split(self.cwd, "/"), sep)
      if self.cwd:len() > trim then output = ".." .. output:sub(-trim) end
      return output .. sep
    end,
    hl = { fg = "breadcrumbs", italic = true },
  },
}

M.filename = {
  -- Path to file
  init = function(self) self.head = vim.fn.fnamemodify(vim.fn.expand("%:h"), modifiers.dirname or nil) end,
  {
    provider = function(self)
      local trim = 40
      local output = table.concat(vim.fn.split(self.head, "/"), sep)
      if self.head:len() > trim then output = ".." .. output:sub(-trim) end
      return output
    end,
    hl = { fg = "breadcrumbs", italic = true },
  },
  -- File name
  {
    {
      provider = function()
        local filetype_icon, filetype_hl = require("nvim-web-devicons").get_icon_by_filetype(vim.bo.filetype)
        return sep .. (filetype_icon and "%#" .. filetype_hl .. "#" .. filetype_icon .. " " or "")
      end,
    },
    {
      provider = function() return vim.fn.expand("%:t") end,
      hl = function()
        if vim.o.background == "light" then
          return { fg = "fg" }
        else
          return { fg = "comment" }
        end
      end,
    },
    hl = { fg = "breadcrumbs", italic = true },
  },
  -- Modifier
  {
    condition = function() return vim.bo.modified end,
    provider = " ",
    hl = { fg = "red" },
  },
}

M.navic = {
  condition = function() return require("nvim-navic").is_available() end,
  init = function(self) self.navic = require("nvim-navic").get_location() end,
  update = "CursorMoved",
  {
    {
      condition = function(self)
        if #self.navic > 0 then
          return true
        else
          return false
        end
      end,
      provider = sep,
      hl = { fg = "breadcrumbs", italic = true },
    },
    {
      provider = function(self) return self.navic end,
    },
  },
}

return M
