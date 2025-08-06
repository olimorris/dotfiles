vim.cmd(string.format("set rtp+=%s", om.home .. "/Code/Neovim/onedarkpro.nvim"))

require("onedarkpro").setup({
  colors = {
    vaporwave = {
      codeblock = "require('onedarkpro.helpers').lighten('bg', 2, 'vaporwave')",
      statusline_bg = "require('onedarkpro.helpers').lighten('bg', 4, 'vaporwave')", -- gray
      statuscolumn_border = "require('onedarkpro.helpers').lighten('bg', 4, 'vaporwave')", -- gray
      ellipsis = "require('onedarkpro.helpers').lighten('bg', 4, 'vaporwave')", -- gray
      picker_results = "require('onedarkpro.helpers').darken('bg', 4, 'vaporwave')",
      picker_selection = "require('onedarkpro.helpers').darken('bg', 8, 'vaporwave')",
      copilot = "require('onedarkpro.helpers').darken('gray', 8, 'vaporwave')",
      breadcrumbs = "require('onedarkpro.helpers').darken('gray', 10, 'vaporwave')",
      light_gray = "require('onedarkpro.helpers').darken('gray', 7, 'vaporwave')",
    },
    onedark = {
      codeblock = "require('onedarkpro.helpers').lighten('bg', 2, 'onedark')",
      statusline_bg = "#2e323b", -- gray
      statuscolumn_border = "#4b5160", -- gray
      ellipsis = "#808080", -- gray
      picker_results = "require('onedarkpro.helpers').darken('bg', 4, 'onedark')",
      picker_selection = "require('onedarkpro.helpers').darken('bg', 8, 'onedark')",
      copilot = "require('onedarkpro.helpers').darken('gray', 8, 'onedark')",
      breadcrumbs = "require('onedarkpro.helpers').darken('gray', 10, 'onedark')",
      light_gray = "require('onedarkpro.helpers').darken('gray', 7, 'onedark')",
    },
    light = {
      codeblock = "require('onedarkpro.helpers').darken('bg', 3, 'onelight')",
      comment = "#bebebe", -- Revert back to original comment colors
      statusline_bg = "#f0f0f0", -- gray
      statuscolumn_border = "#e7e7e7", -- gray
      ellipsis = "#808080", -- gray
      git_add = "require('onedarkpro.helpers').get_preloaded_colors('onelight').green",
      git_change = "require('onedarkpro.helpers').get_preloaded_colors('onelight').yellow",
      git_delete = "require('onedarkpro.helpers').get_preloaded_colors('onelight').red",
      picker_results = "require('onedarkpro.helpers').darken('bg', 5, 'onelight')",
      picker_selection = "require('onedarkpro.helpers').darken('bg', 9, 'onelight')",
      copilot = "require('onedarkpro.helpers').lighten('gray', 8, 'onelight')",
      breadcrumbs = "require('onedarkpro.helpers').lighten('gray', 8, 'onelight')",
      light_gray = "require('onedarkpro.helpers').lighten('gray', 10, 'onelight')",
    },
    rainbow = {
      "${green}",
      "${blue}",
      "${purple}",
      "${red}",
      "${orange}",
      "${yellow}",
      "${cyan}",
    },
  },
  highlights = {
    CodeCompanionChatIcon = { fg = "${green}" },
    CodeCompanionChatToolFailure = { fg = "${gray}", italic = true },
    CodeCompanionChatToolSuccess = { fg = "${gray}", bg = "NONE", italic = true },
    CodeCompanionTokens = { fg = "${gray}", italic = true },
    CodeCompanionVirtualText = { fg = "${gray}", italic = true },

    ["@markup.raw.block.markdown"] = { bg = "${codeblock}" },
    ["@markup.quote.markdown"] = { italic = true, extend = true },

    EdgyNormal = { bg = "${bg}" },
    EdgyTitle = { fg = "${purple}", bold = true },

    EyelinerPrimary = { fg = "${green}" },
    EyelinerSecondary = { fg = "${blue}" },

    NormalFloat = { bg = "${bg}" }, -- Set the terminal background to be the same as the editor
    FloatBorder = { fg = "${gray}", bg = "${bg}" },

    CursorLineNr = { bg = "${bg}", fg = "${fg}", italic = true },
    MatchParen = { fg = "${cyan}" },
    ModeMsg = { fg = "${gray}" }, -- Make command line text lighter
    Search = { bg = "${selection}", fg = "${yellow}", underline = true },
    VimLogo = { fg = { dark = "#81b766", light = "#029632" } },

    -- Dashboard
    SnacksDashboardDesc = { fg = "${blue}", bold = true },
    SnacksDashboardKey = { fg = "${orange}", bold = true, italic = true },
    SnacksDashboardIcon = { fg = "${blue}" },
    SnacksDashboardFooterText = { fg = "${gray}", italic = true },

    -- Copilot
    CopilotSuggestion = { fg = "${copilot}", italic = true },

    -- DAP
    DebugBreakpoint = { fg = "${red}", italic = true },
    DebugHighlightLine = { fg = "${purple}", italic = true },
    NvimDapVirtualText = { fg = "${cyan}", italic = true },

    -- DAP UI
    DapUIBreakpointsCurrentLine = { fg = "${yellow}", bold = true },

    -- Heirline
    Heirline = { bg = "${statusline_bg}" },
    HeirlineStatusColumn = { fg = "${statuscolumn_border}" },
    HeirlineBufferline = { fg = { dark = "#939aa3", light = "#6a6a6a" } },
    HeirlineWinbar = { fg = "${breadcrumbs}", italic = true },
    HeirlineWinbarEmphasis = { fg = "${fg}", italic = true },

    -- Luasnip
    LuaSnipChoiceNode = { fg = "${yellow}" },
    LuaSnipInsertNode = { fg = "${yellow}" },

    -- Neotest
    NeotestAdapterName = { fg = "${purple}", bold = true },
    NeotestFocused = { bold = true },
    NeotestNamespace = { fg = "${blue}", bold = true },

    -- Nvim UFO
    UfoFoldedEllipsis = { fg = "${yellow}" },

    -- Snacks
    SnacksPicker = { bg = "${picker_results}" },
    SnacksPickerDir = { fg = "${gray}", italic = true },
    SnacksPickerBorder = { fg = "${picker_results}", bg = "${picker_results}" },
    SnacksPickerListCursorLine = { bg = "${picker_selection}" },
    SnacksPickerPrompt = { bg = "${picker_results}", fg = "${purple}", bold = true },
    SnacksPickerSelected = { bg = "${picker_results}", fg = "${orange}" },
    SnacksPickerTitle = { bg = "${purple}", fg = "${picker_results}", bold = true },
    SnacksPickerToggle = { bg = "${purple}", fg = "${picker_results}", italic = true },
    SnacksPickerTotals = { bg = "${picker_results}", fg = "${purple}", bold = true },
    SnacksPickerUnselected = { bg = "${picker_results}" },

    SnacksPickerPreview = { bg = "${bg}" },
    SnacksPickerPreviewBorder = { fg = "${bg}", bg = "${bg}" },
    SnacksPickerPreviewTitle = { bg = "${green}", fg = "${bg}", bold = true },

    -- Virt Column
    VirtColumn = { fg = "${indentline}" },
  },

  caching = false,
  cache_path = vim.fn.expand(vim.fn.stdpath("cache") .. "/onedarkpro_dotfiles"),

  styles = {
    tags = "italic",
    methods = "bold",
    functions = "bold",
    keywords = "italic",
    comments = "italic",
    parameters = "italic",
    conditionals = "italic",
    virtual_text = "italic",
  },
  options = {
    cursorline = true,
    -- transparency = true,
    -- highlight_inactive_windows = true,
  },
})

--=============================================================================
-- Functions
--=============================================================================

---Helper function to change the theme based on mode
---@param mode string The mode to set the theme for ("dark" or "light")
---@param theme string The name of the theme to apply
---@return nil
local function change_theme(mode, theme)
  vim.cmd("set background=" .. mode)
  vim.cmd("colorscheme " .. theme)
end

---Global function to toggle between dark and light themes
---@param mode? string Optional mode to set the theme to ("dark" or "light").
---@return nil
function om.ToggleTheme(mode)
  local themes = {
    dark = "vaporwave",
    light = "onelight",
  }

  if mode then
    change_theme(mode, themes[mode])
  else
    if vim.o.background == "dark" then
      change_theme("light", themes.light)
    else
      change_theme("dark", themes.dark)
    end
  end

  local utils = require("heirline.utils")
  utils.on_colorscheme(require("onedarkpro.helpers").get_colors())
end

--=============================================================================
-- Autocommands
--=============================================================================
om.create_autocmd("User", {
  pattern = "OneDarkProRefreshedCache",
  callback = function(args)
    require("onedarkpro.extra").setup({ silent = true, user_config = true })
    vim.notify("Built OneDarkPro extras", vim.log.levels.INFO, {
      title = "Dotfiles",
    })
  end,
})
