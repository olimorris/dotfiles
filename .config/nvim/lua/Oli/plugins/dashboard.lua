local M = {}

function M.setup()
  local ok, alpha = om.safe_require("alpha")
  if not ok then
    return
  end

  local dashboard = require("alpha.themes.dashboard")

  -- Header
  dashboard.section.header.val = {
    [[███    ██ ███████  ██████  ██    ██ ██ ███    ███]],
    [[████   ██ ██      ██    ██ ██    ██ ██ ████  ████]],
    [[██ ██  ██ █████   ██    ██ ██    ██ ██ ██ ████ ██]],
    [[██  ██ ██ ██      ██    ██  ██  ██  ██ ██  ██  ██]],
    [[██   ████ ███████  ██████    ████   ██ ██      ██]],
  }
  dashboard.section.header.opts.hl = "AlphaHeader"

  local function button(sc, txt, keybind, keybind_opts)
    local b = dashboard.button(sc, txt, keybind, keybind_opts)
    b.opts.hl = "AlphaButtonText"
    b.opts.hl_shortcut = "AlphaButtonShortcut"
    return b
  end
  dashboard.section.buttons.val = {
    button("s", "   Load session", ':lua require("persisted").load()<CR>'),
    button("b", "   Bookmarks", ":Telescope harpoon marks<CR>"),
    button("r", "   Recently used files", ":Telescope frecency<CR>"),
    button("n", "   New file", ":ene <BAR> startinsert <CR>"),
    button("f", "   Find file", ":Telescope find_files hidden=true path_display=smart<CR>"),
    button("p", "   Find project", ":Telescope project<CR>"),
    button("w", "   Find word", ":Telescope live_grep path_display=smart<CR>"),
    button("u", "   Update plugins", ':lua om.PackerSync()<CR>'), -- Packer sync
    button("q", "   Quit Neovim", ":qa<CR>"),
  }
  dashboard.section.buttons.opts = {
    spacing = 0,
  }

  -- Footer
  local function footer()
    local total_plugins = #vim.tbl_keys(packer_plugins)
    local datetime = os.date(" %d-%m-%Y")
    local version = vim.version()
    local nvim_version_info = "   Neovim v" .. version.major .. "." .. version.minor .. "." .. version.patch

    return datetime .. "   " .. total_plugins .. " plugins" .. nvim_version_info
  end
  dashboard.section.footer.val = footer()
  dashboard.section.footer.opts.hl = "AlphaFooter"

  -- Layout
  dashboard.config.layout = {
    { type = "padding", val = 2 },
    dashboard.section.header,
    { type = "padding", val = 2 },
    dashboard.section.buttons,
    { type = "padding", val = 1 },
    dashboard.section.footer,
  }

  dashboard.opts.opts.noautocmd = true

  alpha.setup(dashboard.opts)
end

return M
