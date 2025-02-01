local conditions = require("heirline.conditions")
local bit = require("bit")

local sep = "  "

local Spacer = {
  provider = " ",
}

local VimLogo = {
  provider = " ",
  hl = "VimLogo",
}

local Filepath = {
  static = {
    modifiers = {
      dirname = ":s?/Users/Oli/.dotfiles?dotfiles?:s?.config/nvim/lua/Oli?Neovim?:s?/Users/Oli/Code?Code?",
    },
  },
  init = function(self)
    self.current_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")

    self.filepath = vim.fn.fnamemodify(self.current_dir, self.modifiers.dirname or nil)
    self.short_path = vim.fn.fnamemodify(vim.fn.expand("%:h"), self.modifiers.dirname or nil)
    if self.filepath == "" then
      self.filepath = "[No Name]"
    end
  end,
  hl = "HeirlineWinbar",
  {
    condition = function(self)
      return self.filepath ~= "."
    end,
    flexible = 2,
    {
      provider = function(self)
        return table.concat(vim.fn.split(self.filepath, "/"), sep) .. sep
      end,
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

local FileIcon = {
  init = function(self)
    self.icon, self.icon_color =
      require("nvim-web-devicons").get_icon_color_by_filetype(vim.bo.filetype, { default = true })
  end,
  provider = function(self)
    return self.icon and (self.icon .. " ")
  end,
  hl = function(self)
    return { fg = self.icon_color }
  end,
}

local FileType = {
  condition = function()
    return vim.bo.filetype ~= ""
  end,
  FileIcon,
}

local FileName = {
  static = {
    modifiers = {
      dirname = ":s?/Users/Oli/.dotfiles?dotfiles?:s?.config/nvim/lua?Neovim?:s?/Users/Oli/Code?Code?",
    },
  },
  init = function(self)
    local filename
    local has_oil, oil = pcall(require, "oil")
    if has_oil then
      filename = oil.get_current_dir()
    end
    if not filename then
      filename =
        vim.fn.fnamemodify(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":."), self.modifiers.dirname or nil)
    end
    if filename == "" then
      self.path = ""
      self.name = "[No Name]"
      return
    end
    -- now, if the filename would occupy more than 90% of the available
    -- space, we trim the file path to its initials
    if not conditions.width_percent_below(#filename, 0.90) then
      filename = vim.fn.pathshorten(filename)
    end

    self.path = filename:match("^(.*)/")
    self.name = filename:match("([^/]+)$")
  end,
  {
    provider = function(self)
      if self.path then
        return self.path .. "/"
      end
    end,
    hl = "HeirlineWinbar",
  },
  {
    provider = function(self)
      return self.name
    end,
    hl = "HeirlineWinbarEmphasis",
  },
  on_click = {
    callback = function(self)
      require("aerial").toggle()
    end,
    name = "wb_filename_click",
  },
}
local FileFlags = {
  {
    condition = function()
      return vim.bo.modified
    end,
    provider = " ",
    hl = { fg = "red" },
  },
  {
    condition = function()
      return not vim.bo.modifiable or vim.bo.readonly
    end,
    provider = " ",
    hl = { fg = "blue" },
  },
}

-- Inspired by:
-- https://github.com/eli-front/nvim-config/blob/5a225e1e6de3d6f1bdca2025602c3e7a4917e31b/lua/elifront/utils/status/init.lua#L32
local Symbols = {
  init = function(self)
    self.symbols = require("aerial").get_location(true) or {}
  end,
  update = "CursorMoved",
  {
    condition = function(self)
      if vim.tbl_isempty(self.symbols) then
        return false
      end
      return true
    end,
    {
      flexible = 3,
      {
        provider = function(self)
          local symbols = {}

          table.insert(symbols, { provider = sep })

          for i, d in ipairs(self.symbols) do
            local symbol = {
              -- Name
              { provider = string.gsub(d.name, "%%", "%%%%"):gsub("%s*->%s*", "") },

              -- On-Click action
              on_click = {
                minwid = self.encode_pos(d.lnum, d.col, self.winnr),
                callback = function(_, minwid)
                  local lnum, col, winnr = self.decode_pos(minwid)
                  vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), { lnum, col })
                end,
                name = "wb_symbol_click",
              },
            }

            -- Icon
            local hlgroup = string.format("Aerial%sIcon", d.kind)
            table.insert(symbol, 1, {
              provider = string.format("%s", d.icon),
              hl = (vim.fn.hlexists(hlgroup) == 1) and hlgroup or nil,
            })

            if #self.symbols >= 1 and i < #self.symbols then
              table.insert(symbol, { provider = sep })
            end

            table.insert(symbols, symbol)
          end

          self[1] = self:new(symbols, 1)
        end,
      },
      {
        provider = "",
      },
    },
    hl = "Comment",
  },
}

return {
  static = {
    encode_pos = function(line, col, winnr)
      return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr)
    end,
    decode_pos = function(c)
      return bit.rshift(c, 16), bit.band(bit.rshift(c, 6), 1023), bit.band(c, 63)
    end,
  },
  Spacer,
  -- Filepath,
  FileType,
  FileName,
  FileFlags,
  Symbols,
  { provider = "%=" },
  VimLogo,
}
