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
  {
    provider = function()
      local cwd = vim.fn.fnamemodify(vim.loop.cwd(), modifiers.dirname or nil)
      return " " .. table.concat(vim.fn.split(cwd, "/"), sep) .. " "
    end,
    hl = { fg = "gray", bg = "statusline_bg", italic = true },
  },
  LeftSlantEnd,
}

M.filename = {
  -- Path to file
  {
    provider = function()
      local head = vim.fn.fnamemodify(vim.fn.expand("%:h"), modifiers.dirname or nil)
      return " " .. table.concat(vim.fn.split(head, "/"), sep)
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
      hl = { fg = "comment" }
    },
    hl = { fg = "breadcrumbs", italic = true },
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
