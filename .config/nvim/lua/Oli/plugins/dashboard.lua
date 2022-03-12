local M = {}

function M.setup()
  local ok, alpha = om.safe_require("alpha")
  if not ok then
    return
  end

  local dashboard = require("alpha.themes.dashboard")

  local function pick_color()
    local colors = {
      "AlphaHeader1",
      "AlphaHeader2",
      "AlphaHeader3",
      "AlphaHeader4",
      "AlphaHeader5",
      "AlphaHeader6",
      "AlphaHeader7",
    }
    return colors[math.random(#colors)]
  end

  -- Header
  dashboard.section.header.val = {
    [[ _______             ____   ____.__         ]],
    [[ \      \   ____  ___\   \ /   /|__| _____  ]],
    [[ /   |   \_/ __ \/  _ \   Y   / |  |/     \ ]],
    [[/    |    \  ___(  <_> )     /  |  |  Y Y  \]],
    [[\____|__  /\___  >____/ \___/   |__|__|_|  /]],
    [[        \/     \/                        \/ ]],
  }
  dashboard.section.header.opts.hl = pick_color()

  -- Button menu
  local set_color = pick_color()

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
    button("u", "   Update plugins", ":PS<CR>"), -- Packer sync
    button("q", "   Quit Neovim", ":qa<CR>"),
  }
  dashboard.section.buttons.opts = {
    spacing = 0,
  }

  -- Footer
  dashboard.section.footer.val = require("alpha.fortune")
  dashboard.section.footer.opts.hl = "AlphaFooter"

  -- Layout
  dashboard.config.layout = {
    { type = "padding", val = 1 },
    dashboard.section.header,
    { type = "padding", val = 1 },
    dashboard.section.buttons,
    { type = "padding", val = 0 },
    dashboard.section.footer,
  }

  dashboard.opts.opts.noautocmd = true

  alpha.setup(dashboard.opts)
end

return M
