local M = {
  "goolord/alpha-nvim", -- Dashboard for Neovim
}

function M.config()
  local alpha = require("alpha")

  require("alpha.term")
  local dashboard = require("alpha.themes.dashboard")

  -- Terminal header
  dashboard.section.terminal.command = "cat | lolcat --seed=24 "
    .. os.getenv("HOME")
    .. "/.config/nvim/static/neovim.cat"
  dashboard.section.terminal.width = 69
  dashboard.section.terminal.height = 8

  local function button(sc, txt, keybind, keybind_opts)
    local b = dashboard.button(sc, txt, keybind, keybind_opts)
    b.opts.hl = "AlphaButtonText"
    b.opts.hl_shortcut = "AlphaButtonShortcut"
    return b
  end

  dashboard.section.buttons.val = {
    button("l", "   Load session", "<cmd>lua require('persisted').load()<CR>"),
    button("n", "   New file", "<cmd>ene <BAR> startinsert <CR>"),
    button("r", "   Recent files", "<cmd>Telescope frecency workspace=CWD<CR>"),
    button("f", "   Find file", "<cmd>Telescope find_files hidden=true path_display=smart<CR>"),
    button("p", "   Projects", "<cmd>Telescope projects<CR>"),
    button("u", "   Update plugins", "<cmd>lua require('lazy').sync()<CR>"),
    button("q", "   Quit Neovim", "<cmd>qa!<CR>"),
  }
  dashboard.section.buttons.opts = {
    spacing = 0,
  }

  -- Footer
  local function footer()
    local total_plugins = require("lazy").stats().count
    local version = vim.version()
    local nvim_version_info = "  Neovim v" .. version.major .. "." .. version.minor .. "." .. version.patch

    return " " .. total_plugins .. " plugins" .. nvim_version_info
  end

  dashboard.section.footer.val = footer()
  dashboard.section.footer.opts.hl = "AlphaFooter"

  -- Layout
  dashboard.config.layout = {
    { type = "padding", val = 1 },
    dashboard.section.terminal,
    { type = "padding", val = 9 },
    dashboard.section.buttons,
    { type = "padding", val = 1 },
    dashboard.section.footer,
  }

  dashboard.config.opts.noautocmd = true

  alpha.setup(dashboard.opts)
end

return M
