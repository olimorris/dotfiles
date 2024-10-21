local wezterm = require("wezterm")

local M = {}

M.arrow_solid = ""
M.arrow_thin = ""
M.icons = {
  ["cargo"] = wezterm.nerdfonts.dev_rust,
  ["curl"] = wezterm.nerdfonts.mdi_flattr,
  ["docker"] = wezterm.nerdfonts.linux_docker,
  ["docker-compose"] = wezterm.nerdfonts.linux_docker,
  ["fish"] = wezterm.nerdfonts.md_fish,
  ["gh"] = wezterm.nerdfonts.dev_github_badge,
  ["git"] = wezterm.nerdfonts.dev_git,
  ["lg"] = wezterm.nerdfonts.cod_github,
  ["lazygit"] = wezterm.nerdfonts.cod_github,
  ["lua"] = wezterm.nerdfonts.seti_lua,
  ["make"] = wezterm.nerdfonts.seti_makefile,
  ["node"] = wezterm.nerdfonts.mdi_hexagon,
  ["nv"] = wezterm.nerdfonts.custom_vim,
  ["nvim"] = wezterm.nerdfonts.custom_vim,
  ["php"] = wezterm.nerdfonts.dev_php,
  ["psql"] = wezterm.nerdfonts.dev_postgresql,
  ["python"] = wezterm.nerdfonts.dev_python,
  ["ruby"] = wezterm.nerdfonts.dev_ruby,
  ["sudo"] = wezterm.nerdfonts.fa_hashtag,
  ["vim"] = wezterm.nerdfonts.dev_vim,
  ["workspace"] = wezterm.nerdfonts.dev_terminal,
  ["wezterm"] = wezterm.nerdfonts.dev_terminal,
}

---Set the title of the tab
---@param tab table
---@param max_width number
local function set_title(tab, max_width)
  local title = (tab.tab_title and #tab.tab_title > 0) and tab.tab_title or tab.active_pane.title
  local process, other = title:match("^(%S+)%s*%-?%s*%s*(.*)$")

  if M.icons[process] then
    title = M.icons[process] .. " " .. (other or "")
  end

  local is_zoomed = false
  for _, pane in ipairs(tab.panes) do
    if pane.is_zoomed then
      is_zoomed = true
      break
    end
  end
  if is_zoomed then -- or (#tab.panes > 1 and not tab.is_active) then
    title = " " .. title
  end

  title = wezterm.truncate_right(title, max_width - 3)
  return " " .. title .. " "
end

---@param config table
function M.setup(config)
  config.use_fancy_tab_bar = false
  config.tab_bar_at_bottom = true
  config.hide_tab_bar_if_only_one_tab = true
  config.tab_max_width = 32
  config.unzoom_on_switch_pane = true

  wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local title = set_title(tab, max_width)
    local colors = config.resolved_palette

    local ret = tab.is_active
        and {
          { Attribute = { Intensity = "Bold" } },
          { Attribute = { Italic = true } },
        }
      or {}
    ret[#ret + 1] = { Text = title }

    return ret
  end)
end

return M
