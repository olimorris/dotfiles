local M = {}

-- We need to load nvimtrees global options as part of the setup function
M.setup = function()
  vim.g.nvim_tree_indent_markers = 0 -- Do not show indentation marks
  vim.g.nvim_tree_highlight_opened_files = 2 -- Highlight icons and folder/file names if opened
  vim.g.nvim_tree_show_icons = {
    git = 0,
    files = 1,
    folders = 1,
    folder_arrows = 1,
  }
end

M.config = function()
  local ok, nvimtree = om.safe_require("nvim-tree")
  if not ok then
    return
  end

  nvimtree.setup({
    ignore_ft_on_setup = {
      "aerial",
      "alpha",
      "dashboard",
      "startify",
      "terminal",
      "quickfix",
    }, -- will not open on setup if the filetype is in this list
    hijack_cursor = true, -- put the cursor at the start of the filename
    git = { ignore = false },
    filters = {
      dotfiles = false,
      custom = { ".git", "node_modules", ".cache", ".vscode", ".DS_Store" },
    },
    view = { width = 35 },
  })
end

return M
