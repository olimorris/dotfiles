local M = {}

function M.setup()
  local ok, bufferline = om.safe_require("bufferline")
  if not ok then
    return
  end

  local colors = require("onedarkpro").get_colors(vim.g.onedarkpro_theme)

  bufferline.setup({
    options = {
      numbers = function(opts)
        return string.format("%s:", opts.ordinal)
      end,
      tab_size = 15,
      left_trunc_marker = "",
      right_trunc_marker = "",
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
          filetype = "aerial",
          text = "Aerial",
          highlight = "BufferlineOffset",
          text_align = "center",
        },
      },
      custom_areas = {
        left = function()
          return {
            { text = "    ", fg = colors.vim },
          }
        end,
      },
    },
    highlights = {
      background = {
        bg = colors.bg,
      },
      buffer = {
        fg = colors.gray,
      },
      duplicate = {
        fg = colors.gray,
        bg = colors.bg,
        italic = true,
      },
      fill = {
        bg = colors.bg,
      },
      modified = {
        fg = colors.gray,
        bg = colors.bg,
      },
      numbers = {
        fg = colors.gray,
        bg = colors.bg,
        italic = true,
      },
      pick = {
        fg = colors.purple,
        bg = colors.bg,
      },
      separator = {
        fg = colors.bg,
        bg = colors.bg,
      },
      tab = {
        fg = colors.gray,
        bg = colors.bg,
      },
      buffer_selected = {
        fg = colors.bufferline_text_focus,
        bg = colors.statusline_bg,
        bold = true,
        italic = false,
      },
      duplicate_selected = {
        fg = colors.purple,
        bg = colors.statusline_bg,
        italic = true,
      },
      indicator_selected = {
        bg = colors.statusline_bg,
      },
      modified_selected = {
        fg = colors.red,
        bg = colors.statusline_bg,
      },
      numbers_selected = {
        fg = colors.purple,
        bg = colors.statusline_bg,
        bold = false,
        italic = true,
      },
      pick_selected = {
        fg = colors.gray,
        bg = colors.statusline_bg,
        bold = true,
        italic = false,
      },
      tab_selected = {
        fg = colors.fg,
        bg = colors.statusline_bg,
        bold = true,
      },
      buffer_visible = {
        fg = colors.gray,
        bg = colors.statusline_bg,
        bold = true,
        italic = false,
      },
      duplicate_visible = {
        bg = colors.statusline_bg,
        italic = true,
      },
      indicator_visible = {
        bg = colors.statusline_bg,
      },
      modified_visible = {
        fg = colors.gray,
        bg = colors.statusline_bg,
      },
      numbers_visible = {
        fg = colors.gray,
        bg = colors.statusline_bg,
        italic = true,
      },
      separator_visible = {
        bg = colors.statusline_bg,
      },
    },
  })
end

return M
