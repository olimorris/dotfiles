local M = {}

M.setup = function()
  local ok, onedarkpro = om.safe_require("onedarkpro", { silent = true })
  if not ok then
    return
  end
  local utils = require("onedarkpro.utils")

  onedarkpro.setup({
    plugins = { polygot = false, telescope = false },
    styles = { comments = "italic", keywords = "bold,italic" },
    options = {
      bold = true,
      italic = true,
      underline = true,
      undercurl = true,
      cursorline = true,
    },
    colors = {
      onedark = {
        vim = "#81b766", -- green
        brackets = "#abb2bf", -- fg / gray
        cursorline = "#2e323b",
        indentline = "#3c414d",

        statusline_div = "#2e323b", -- gray
        statusline_bg = "#2e323b", -- gray
        statusline_text = "#696C77", -- gray

        bufferline_unfocus = utils.lighten(onedarkpro.get_colors("onedark").gray, 0.65),

        telescope_prompt = utils.lighten(onedarkpro.get_colors("onedark").bg, 0.97),
        telescope_results = utils.darken(onedarkpro.get_colors("onedark").bg, 0.85),
      },
      onelight = {
        vim = "#029632", -- green
        brackets = "#e05661", -- red

        statusline_div = "#f0f0f0", -- gray
        statusline_bg = "#f0f0f0", -- gray
        statusline_text = "#b5b5b5", -- gray

        telescope_prompt = utils.darken(onedarkpro.get_colors("onelight").bg, 0.98),
        telescope_results = utils.darken(onedarkpro.get_colors("onelight").bg, 0.95),
      },
    },
    filetype_hlgroups = {
      yaml = { TSField = { fg = "${red}" } },
      ruby = {
        TSParameter = { fg = "${fg}" },
        TSSymbol = { fg = "${cyan}" },
      },
      scss = {
        TSFunction = { fg = "${cyan}" },
        TSProperty = { fg = "${orange}" },
        TSPunctDelimiter = { fg = "${orange}" },
        TSType = { fg = "${red}" },
      },
    },
    hlgroups = {
      ModeMsg = { link = "LineNr" }, -- Make command line text darker
      VertSplit = { fg = "${bg}" }, -- Hide the vertical split line

      -- Highlight brackets with a custom color
      TSPunctBracket = { fg = "${brackets}" },
      TSPunctSpecial = { fg = "${brackets}" },

      -- Aerial plugin
      AerialClassIcon = { fg = "${purple}" },
      AerialConstructorIcon = { fg = "${yellow}" },
      AerialEnumIcon = { fg = "${blue}" },
      AerialFunctionIcon = { fg = "${red}" },
      AerialInterfaceIcon = { fg = "${orange}" },
      AerialMethodIcon = { fg = "${green}" },
      AerialStructIcon = { fg = "${cyan}" },

      -- Alpha (dashboard) plugin
      -- AlphaHeader = {
      --   fg = (vim.o.background == "dark" and "${red}" or "${green}"),
      -- },
      AlphaHeader1 = {
        fg = "${red}",
      },
      AlphaHeader2 = {
        fg = "${cyan}",
      },
      AlphaHeader3 = {
        fg = "${blue}",
      },
      AlphaHeader4 = {
        fg = "${green}",
      },
      AlphaHeader5 = {
        fg = "${yellow}",
      },
      AlphaHeader6 = {
        fg = "${orange}",
      },
      AlphaHeader7 = {
        fg = "${purple}",
      },

      AlphaButtonText = {
        fg = (vim.o.background == "dark" and "${blue}" or "${purple}"),
        style = "bold",
      },
      AlphaButtonShortcut = {
        fg = (vim.o.background == "dark" and "${yellow}" or "${blue}"),
        style = "italic,bold",
      },
      AlphaFooter = { fg = "${fg}", style = "italic" },

      -- LSP plugin
      LspDiagnosticsVirtualTextError = {
        fg = "${red}",
        style = "italic,underline",
      },
      LspDiagnosticsVirtualTextWarning = {
        fg = "${yellow}",
        style = "italic,underline",
      },
      LspDiagnosticsVirtualTextInformation = {
        fg = "${blue}",
        style = "italic,underline",
      },
      LspDiagnosticsVirtualTextHint = {
        fg = "${cyan}",
        style = "italic,underline",
      },

      -- Luasnip
      LuaSnipChoiceNode = { fg = "${yellow}" },
      LuaSnipInsertNode = { fg = "${yellow}" },

      -- Minimap
      MapBase = { fg = "${gray}" },
      MapCursor = { fg = "${purple}", bg = "${cursorline}" },
      -- MapRange = { fg = "${fg}" },

      -- Telescope
      TelescopeBorder = {
        fg = "${telescope_results}",
        bg = "${telescope_results}",
      },
      TelescopePromptBorder = {
        fg = "${telescope_prompt}",
        bg = "${telescope_prompt}",
      },
      TelescopePromptCounter = { fg = "${fg}" },
      TelescopePromptNormal = { fg = "${fg}", bg = "${telescope_prompt}" },
      TelescopePromptPrefix = {
        fg = "${purple}",
        bg = "${telescope_prompt}",
      },
      TelescopePromptTitle = {
        fg = "${telescope_prompt}",
        bg = "${purple}",
      },

      TelescopePreviewTitle = {
        fg = "${telescope_results}",
        bg = "${green}",
      },
      TelescopeResultsTitle = {
        fg = "${telescope_results}",
        bg = "${telescope_results}",
      },

      TelescopeMatching = { fg = "${purple}" },
      TelescopeNormal = { bg = "${telescope_results}" },
      TelescopeSelection = { bg = "${telescope_prompt}" },
    },
  })
  onedarkpro.load()
end

return M
