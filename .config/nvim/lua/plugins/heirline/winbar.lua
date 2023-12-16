local bit = require("bit")

local sep = "  "

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
    on_click = {
      callback = function(self)
        require("telescope.builtin").find_files({
          cwd = self.current_dir,
        })
      end,
      name = "wb_path_click",
    },
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

local Filename = {
  {
    {
      provider = function()
        local filetype_icon, filetype_hl = require("nvim-web-devicons").get_icon_by_filetype(vim.bo.filetype)
        return (filetype_icon and "%#" .. filetype_hl .. "#" .. filetype_icon .. " " or "")
      end,
    },
    {
      provider = function()
        return vim.fn.expand("%:t")
      end,
      hl = function()
        if vim.o.background == "light" then
          return { fg = "fg" }
        else
          return { fg = "comment" }
        end
      end,
    },
    hl = "HeirlineWinbar",
    on_click = {
      callback = function(self)
        require("aerial").toggle()
      end,
      name = "wb_filename_click",
    },
  },
  -- Modifier
  {
    condition = function()
      return vim.bo.modified
    end,
    provider = " ",
    hl = { fg = "red" },
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
      else
        return true
      end
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
    hl = "HeirlineWinbar",
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
  Filepath,
  Filename,
  Symbols,
  { provider = "%=" },
  VimLogo,
}
