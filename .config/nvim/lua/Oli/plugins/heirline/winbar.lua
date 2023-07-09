local M = {}

local sep = "  "
local LeftSlantEnd = {
  provider = "",
  hl = { fg = "statusline_bg", bg = "bg" },
}

local modifiers = {
  dirname = ":s?/Users/Oli/.dotfiles?dotfiles?:s?.config/nvim/lua/Oli?Neovim?:s?/Users/Oli/Code?Code?",
}

M.vim_logo = {
  provider = " ",
  hl = "VimLogo",
}

M.filepath = {
  init = function(self)
    local current_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")

    self.filepath = vim.fn.fnamemodify(current_dir, modifiers.dirname or nil)
    self.short_path = vim.fn.fnamemodify(vim.fn.expand("%:h"), modifiers.dirname or nil)
    if self.filepath == "" then self.filepath = "[No Name]" end
  end,
  hl = "NavicText",
  {
    condition = function(self) return self.filepath ~= "." end,
    flexible = 2,
    {
      provider = function(self) return table.concat(vim.fn.split(self.filepath, "/"), sep) .. sep end,
    },
    {
      provider = function(self)
        local filepath = vim.fn.pathshorten(self.short_path)
        return table.concat(vim.fn.split(self.short_path, "/"), sep) .. sep
      end,
    },
    {
      provider = "",
    },
  },
}

M.filename = {
  {
    {
      provider = function()
        local filetype_icon, filetype_hl = require("nvim-web-devicons").get_icon_by_filetype(vim.bo.filetype)
        return (filetype_icon and "%#" .. filetype_hl .. "#" .. filetype_icon .. " " or "")
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
    hl = "NavicText",
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
    condition = function(self)
      if #self.navic > 0 then
        return true
      else
        return false
      end
    end,
    {
      flexible = 3,
      {
        provider = function(self) return sep .. self.navic end,
      },
      {
        provider = "",
      },
    },
    hl = "NavicText",
  },
}

return M
