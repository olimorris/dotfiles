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
  local ok, file_explorer = om.safe_require("nvim-tree")
  if not ok then
    return
  end

  file_explorer.setup({
    ignore_ft_on_setup = {
      "aerial",
      "alpha",
      "dashboard",
      "startify",
      "terminal",
      "quickfix",
    }, -- will not open on setup if the filetype is in this list
    hijack_cursor = true, -- put the cursor at the start of the filename
    git = { enable = false, ignore = false },
    filters = {
      dotfiles = false,
      custom = { ".git", "node_modules", ".cache", ".vscode", ".DS_Store" },
    },
    actions = {
      open_file = {
        resize_window = true,
      },
    },
    view = {
      allow_resize = true,
      side = "left",
      width = 25,
      hide_root_folder = false,
    },
  })
end

return M
