local ok, bufferline = om.safe_require("bufferline")
if not ok then return end

bufferline.setup({
  options = {
    numbers = function(opts) return string.format("%s:", opts.ordinal) end,
    max_name_length = 13,
    tab_size = 15,
    indicator = "",
    show_buffer_icons = false,
    show_buffer_close_icons = false,
    show_close_icon = false,
    separator_style = "thin",
    offsets = {
      {
        filetype = "neo-tree",
        text = "Neo Tree",
        highlight = "BufferlineOffset",
        text_align = "center",
      },
      {
        filetype = "neotest-summary",
        text = "Neo Test",
        highlight = "BufferlineOffset",
        text_align = "center",
      },
      {
        filetype = "aerial",
        text = "Aerial",
        highlight = "BufferlineOffset",
        text_align = "center",
      },
    },
    custom_areas = {
      left = function()
        return {
          { text = "    ", fg = om.get_highlight("BufferlineVim").fg },
        }
      end,
    },
    custom_filter = function(buf_number, buf_numbers)
      if vim.bo[buf_number].filetype ~= "dap-repl" then return true end
    end,
  },
  highlights = {
    background = {
      bg = {
        attribute = "bg",
        highlight = "BufferlineNormal",
      },
    },
    buffer = {
      fg = {
        attribute = "fg",
        highlight = "BufferlineNormal",
      },
    },
    duplicate = {
      fg = {
        attribute = "fg",
        highlight = "BufferlineNormal",
      },
      bg = {
        attribute = "bg",
        highlight = "BufferlineNormal",
      },
      italic = true,
    },
    fill = {
      bg = {
        attribute = "bg",
        highlight = "BufferlineNormal",
      },
    },
    modified = {
      fg = {
        attribute = "fg",
        highlight = "BufferlineNormal",
      },
      bg = {
        attribute = "bg",
        highlight = "BufferlineNormal",
      },
    },
    numbers = {
      fg = {
        attribute = "fg",
        highlight = "BufferlineNormal",
      },
      bg = {
        attribute = "bg",
        highlight = "BufferlineNormal",
      },
      italic = true,
    },
    pick = {
      fg = {
        attribute = "fg",
        highlight = "BufferlineSelected",
      },
      bg = {
        attribute = "bg",
        highlight = "BufferlineNormal",
      },
    },
    separator = {
      fg = {
        attribute = "bg",
        highlight = "BufferlineNormal",
      },
      bg = {
        attribute = "bg",
        highlight = "BufferlineNormal",
      },
    },
    tab = {
      fg = {
        attribute = "fg",
        highlight = "BufferlineNormal",
      },
      bg = {
        attribute = "bg",
        highlight = "BufferlineNormal",
      },
    },
    buffer_selected = {
      fg = {
        attribute = "fg",
        highlight = "Normal",
      },
      bg = {
        attribute = "bg",
        highlight = "BufferlineSelected",
      },
      bold = true,
      italic = false,
    },
    duplicate_selected = {
      fg = {
        attribute = "fg",
        highlight = "BufferlineSelected",
      },
      bg = {
        attribute = "bg",
        highlight = "BufferlineSelected",
      },
      italic = true,
    },
    indicator_selected = {
      bg = {
        attribute = "bg",
        highlight = "BufferlineSelected",
      },
    },
    modified_selected = {
      fg = {
        attribute = "fg",
        highlight = "DiagnosticError",
      },
      bg = {
        attribute = "bg",
        highlight = "BufferlineSelected",
      },
    },
    numbers_selected = {
      fg = {
        attribute = "fg",
        highlight = "BufferlineSelected",
      },
      bg = {
        attribute = "bg",
        highlight = "BufferlineSelected",
      },
      bold = false,
      italic = true,
    },
    pick_selected = {
      fg = {
        attribute = "fg",
        highlight = "BufferlineNormal",
      },
      bg = {
        attribute = "bg",
        highlight = "BufferlineSelected",
      },
      bold = true,
      italic = false,
    },
    separator_selected = {
      fg = {
        attribute = "fg",
        highlight = "DiagnosticInfo",
      },
      bg = {
        attribute = "fg",
        highlight = "DiagnosticError",
      },
    },
    tab_selected = {
      fg = {
        attribute = "fg",
        highlight = "Normal",
      },
      bg = {
        attribute = "bg",
        highlight = "BufferlineSelected",
      },
      bold = true,
    },
    buffer_visible = {
      fg = {
        attribute = "fg",
        highlight = "BufferlineNormal",
      },
      bg = {
        attribute = "bg",
        highlight = "BufferlineSelected",
      },
      bold = true,
      italic = false,
    },
    duplicate_visible = {
      bg = {
        attribute = "bg",
        highlight = "BufferlineSelected",
      },
      italic = true,
    },
    indicator_visible = {
      bg = {
        attribute = "bg",
        highlight = "BufferlineSelected",
      },
    },
    modified_visible = {
      fg = {
        attribute = "fg",
        highlight = "BufferlineNormal",
      },
      bg = {
        attribute = "bg",
        highlight = "BufferlineSelected",
      },
    },
    numbers_visible = {
      fg = {
        attribute = "fg",
        highlight = "BufferlineNormal",
      },
      bg = {
        attribute = "bg",
        highlight = "BufferlineSelected",
      },
      italic = true,
    },
    separator_visible = {
      bg = {
        attribute = "bg",
        highlight = "BufferlineSelected",
      },
    },
  },
})
