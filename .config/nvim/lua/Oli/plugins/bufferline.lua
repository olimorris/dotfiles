local M = {}

function M.setup()
  local ok, bufferline = om.safe_require("cokeline")
  if not ok then
    return
  end

  local spacer = "  "
  local colors = require("onedarkpro").get_colors(vim.g.onedarkpro_style)

  bufferline.setup({

    show_if_buffers_are_at_least = 2,

    buffers = {
      new_buffers_position = "last",
      filter_visible = function(buffer)
        return buffer.type ~= "terminal" and buffer.type ~= "quickfix" and buffer.filetype ~= "alpha"
      end,
    },

    rendering = { max_buffer_width = 25 },

    default_hl = {
      fg = function(buffer)
        return buffer.is_focused and colors.purple or colors.gray
      end,
      bg = "NONE",
      style = function(buffer)
        return buffer.is_focused and "bold" or "NONE"
      end,
    },

    components = {
      -- Buffer index
      {
        text = function(buffer)
          return buffer.index ~= 1 and spacer or ""
        end,
      },
      {
        text = function(buffer)
          return buffer.index .. ": "
        end,
        style = function(buffer)
          return buffer.is_focused and "bold" or nil
        end,
      },
      -- Buffer name
      {
        text = function(buffer)
          return buffer.unique_prefix
        end,
        fg = function(buffer)
          return buffer.is_focused and colors.purple or colors.gray
        end,
        style = "italic",
      },
      {
        text = function(buffer)
          return buffer.filename
        end,
        style = function(buffer)
          return buffer.is_focused and "bold" or nil
        end,
      },
      -- Buffer modified
      {
        text = function(buffer)
          return buffer.is_modified and " ●" or ""
        end,
        truncation = { priority = 1 },
        fg = function(buffer)
          return buffer.is_focused and colors.red
        end,
      },
      { text = spacer },
    },

    sidebar = {
      filetype = "NvimTree",
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
