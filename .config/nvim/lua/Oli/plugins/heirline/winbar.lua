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
  init = function(self) self.cwd = vim.fn.fnamemodify(vim.fn.getcwd(0), modifiers.dirname or nil) end,
  hl = { fg = "breadcrumbs", italic = true },

  flexible = 1,
  {
    -- evaluates to the full-length path
    provider = function(self)
      local trail = self.cwd:sub(-1) == "/" and "" or "/"
      return table.concat(vim.fn.split(self.cwd .. trail, "/"), sep) .. sep
    end,
  },
  {
    -- evaluates to the shortened path
    provider = function(self)
      local cwd = vim.fn.pathshorten(self.cwd)
      return table.concat(vim.fn.split(cwd, "/"), sep) .. sep
    end,
  },
  {
    -- evaluates to "", hiding the component
    provider = "",
  },
}

M.filepath = {
  -- Path to file
  init = function(self)
    self.filename = vim.fn.fnamemodify(vim.fn.expand("%:h"), modifiers.dirname or nil)
    if self.filename == "" then self.filename = "[No Name]" end
  end,
  hl = { fg = "breadcrumbs", italic = true },

  flexible = 2,
  {
    provider = function(self) return table.concat(vim.fn.split(self.filename, "/"), sep) end,
  },
  {
    provider = function(self)
      local filename = vim.fn.pathshorten(self.filename)
      return table.concat(vim.fn.split(filename, "/"), sep)
    end,
  },
  {
    provider = "",
  },
}

M.filename = {
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
    hl = { fg = "breadcrumbs", italic = true },
  },
}

return M
