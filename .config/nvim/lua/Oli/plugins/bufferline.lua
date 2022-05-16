local M = {}

function M.setup()
  local ok, bufferline = om.safe_require("cokeline")
  if not ok then
    return
  end

  local spacer = " "
  local separator = ""
  local colors = vim.g.onedarkpro_colors

  if not colors then
    return
  end

  bufferline.setup({
    show_if_buffers_are_at_least = 1,

    buffers = {
      new_buffers_position = "last",
      filter_visible = function(buffer)
        return buffer.type ~= "terminal" and buffer.type ~= "quickfix"
      end,
    },

    rendering = { max_buffer_width = 25 },

    default_hl = {
      fg = function(buffer)
        if buffer.is_focused then
          return (vim.o.background == "light" and colors.black or colors.bufferline_text_focus)
        else
          return colors.gray
        end
      end,
      bg = "NONE",
      style = function(buffer)
        return buffer.is_focused and "bold"
      end,
    },

    components = {
      -- Vim logo
      {
        text = function(buffer)
          if buffer.index == 1 then
            return "   "
          else
            return ""
          end
        end,
        fg = colors.vim,
      },
      {
        text = separator,
        fg = function(buffer)
          return (buffer.is_focused and colors.statusline_bg or colors.bg)
        end,
      },
      -- Buffer index
      {
        text = function(buffer)
          return buffer.index ~= 1 and spacer or " "
        end,
        bg = function(buffer)
          return buffer.is_focused and colors.statusline_bg
        end,
      },
      {
        text = function(buffer)
          return buffer.index .. ": "
        end,
        fg = function(buffer)
          return buffer.is_focused and colors.purple
        end,
        bg = function(buffer)
          return buffer.is_focused and colors.statusline_bg
        end,
        style = "italic",
      },
      -- Buffer unique name
      {
        text = function(buffer)
          return buffer.unique_prefix
        end,
        bg = function(buffer)
          return buffer.is_focused and colors.statusline_bg
        end,
        fg = function(buffer)
          return buffer.is_focused and colors.purple or colors.gray
        end,
        style = "italic",
      },
      -- Buffer name
      {
        text = function(buffer)
          return buffer.filename .. " "
        end,
        bg = function(buffer)
          return buffer.is_focused and colors.statusline_bg
        end,
      },
      -- Buffer modified
      {
        text = function(buffer)
          return buffer.is_modified and "●" or ""
        end,
        truncation = { priority = 1 },
        bg = function(buffer)
          return buffer.is_focused and colors.statusline_bg
        end,
        fg = function(buffer)
          return buffer.is_focused and colors.red
        end,
      },
      {
        text = separator,
        fg = colors.bg,
        bg = function(buffer)
          return buffer.is_focused and colors.statusline_bg
        end,
      },
      { text = spacer },
    },

    sidebar = {
      filetype = "neo-tree",
      components = {
        {
          text = "  File Explorer",
          fg = colors.yellow,
          bg = "NONE",
          style = "bold",
        },
      },
    },
  })
end

return M
