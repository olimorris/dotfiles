local M = {}

M.config = function()
  local ok, file_explorer = om.safe_require("neo-tree")
  if not ok then
    return
  end

  file_explorer.setup({
    close_if_last_window = true,
    -- git_status_async = false,
    enable_git_status = true,
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
      modified = {
        symbol = "[+]",
        highlight = "NeoTreeModified",
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
