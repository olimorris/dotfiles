local M = {}

M.setup = function()
  local ok, onedarkpro = pcall(load, "onedarkpro")
  if not ok then
    return
  end

  onedarkpro.setup({
    plugins = { polygot = false },
    styles = { comments = "italic", keywords = "italic", virtual_text = "italic,underline" },
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

        ghost_text = "#555961",

        statusline_bg = "#2e323b", -- gray

        bufferline_text_focus = "#949aa2",
      },
      onelight = {
        vim = "#029632", -- green
        brackets = "#e05661", -- red

        ghost_text = "#c3c3c3",

        statusline_bg = "#f0f0f0", -- gray
      },
    },
    filetype_hlgroups = {
      lua = {
        Hlargs = { fg = "${red}", style = "italic" },
      },
      yaml = { TSField = { fg = "${red}" } },
      python = {
        TSFunction = { fg = "${blue}", style = "bold" },
      },
      ruby = {
        Hlargs = { fg = "${red}" },
        TSFunction = { fg = "${blue}", style = "bold" },
        TSInclude = { fg = "${blue}", style = "italic" },
        TSParameter = { fg = "${fg}", style = "italic" },
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
      AlphaHeader = {
        fg = (vim.o.background == "dark" and "${green}" or "${red}"),
      },
      AlphaButtonText = {
        fg = "${blue}",
        style = "bold",
      },
      AlphaButtonShortcut = {
        fg = (vim.o.background == "dark" and "${purple}" or "${yellow}"),
        style = "italic,bold",
      },
      AlphaFooter = { fg = "${gray}", style = "italic" },

      -- Cmp
      GhostText = { fg = "${ghost_text}" },

      -- Fidget plugin
      FidgetTitle = { fg = "${purple}" },
      FidgetTask = { fg = "${gray}" },

      -- Luasnip
      LuaSnipChoiceNode = { fg = "${yellow}" },
      LuaSnipInsertNode = { fg = "${yellow}" },

      -- Minimap
      MapBase = { fg = "${gray}" },
      MapCursor = { fg = "${purple}", bg = "${cursorline}" },
      -- MapRange = { fg = "${fg}" },

      -- Scrollbar
      ScrollView = { bg = "${gray}"},
    },
  })
end

return M
