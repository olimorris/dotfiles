-- Inspired by: https://github.com/folke/dot/blob/master/config/wezterm/tabs.lua
local wezterm = require("wezterm")

local function leader(window)
  if window:leader_is_active() then
    return " ! "
  end
  return ""
end

local function tabs(config)
  local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

  config.use_fancy_tab_bar = false
  config.tab_bar_at_bottom = true
  config.hide_tab_bar_if_only_one_tab = false

  local colors = wezterm.color.load_scheme(config.color_scheme_dirs[1] .. "/" .. config.color_scheme .. ".toml")

  tabline.setup({
    options = {
      icons_enabled = false,
      component_separators = {
        left = "",
        right = "",
      },
      section_separators = {
        left = "",
        right = "",
      },
      tab_separators = {
        left = "",
        right = "",
      },
      theme_overrides = {
        normal_mode = {
          a = { fg = colors.background, bg = colors.ansi[5] },
          b = { fg = colors.indexed[59], bg = colors.background },
          c = { fg = colors.indexed[59], bg = colors.background },
        },
        copy_mode = {
          a = { fg = colors.background, bg = colors.ansi[4] },
          b = { fg = colors.ansi[4], bg = colors.background },
          c = { fg = colors.foreground, bg = colors.background },
        },
        search_mode = {
          a = { fg = colors.background, bg = colors.ansi[3] },
          b = { fg = colors.ansi[3], bg = colors.background },
          c = { fg = colors.foreground, bg = colors.background },
        },
        -- Defining colors for a new key table
        window_mode = {
          a = { fg = colors.background, bg = colors.ansi[6] },
          b = { fg = colors.ansi[6], bg = colors.background },
          c = { fg = colors.foreground, bg = colors.background },
        },
        -- Default tab colors
        tab = {
          active = { fg = colors.ansi[6], bg = colors.background },
          inactive = { fg = colors.indexed[59], bg = colors.background },
          inactive_hover = { fg = colors.ansi[6], bg = colors.background },
        },
      },
    },
    sections = {
      tabline_a = { leader },
      tabline_b = {},
      tabline_c = {},
      tab_active = { "index" .. "", { "process", padding = { left = 0, right = 1 } } },
      tab_inactive = { "index", { "process", padding = { left = 0, right = 1 } } },
      tabline_x = { "ram", "cpu", "battery", "datetime" },
      tabline_y = {},
      tabline_z = {},
    },
    extensions = {
      "resurrect",
    },
  })
end

return tabs
