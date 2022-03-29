local M = {}

M.setup = function()
  vim.g.nvim_tree_indent_markers = 0 -- Do not show indentation marks
  vim.g.nvim_tree_highlight_opened_files = 2 -- Highlight icons and folder/file names if opened
  vim.g.nvim_tree_show_icons = {
    git = 0,
    files = 1,
    folders = 1,
    folder_arrows = 0,
  }
  vim.g.nvim_tree_icons = {
    folder = {
      open = "",
      default = "",
      empty = "ﰊ",
    },
  }
end

M.config = function()
  local ok, file_explorer = om.safe_require("neo-tree")
  if not ok then
    return
  end

  file_explorer.setup({
    close_if_last_window = true,
    git_status_async = false,
    enable_git_status = false,
    enable_diagnostics = false,
    default_component_configs = {
      icon = {
        folder_open = "",
        folder_closed = "",
        folder_empty = "ﰊ",
        default = "*",
      },
      indent = {
        with_markers = false,
      },
    },
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
      },
    },
    window = {
      width = 35,
    },
  })
end

return M
