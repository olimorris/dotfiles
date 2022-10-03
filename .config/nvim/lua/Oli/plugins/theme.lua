---@diagnostic disable: need-check-nil
local M = {}

M.setup = function()
  local ok, onedarkpro = pcall(load, "onedarkpro")
  if not ok then
    return
  end

  onedarkpro.setup({
    caching = true,
    plugins = {
      barbar = false,
      lsp_saga = false,
      marks = false,
      polygot = false,
      startify = false,
      telescope = false,
      trouble = false,
      vim_ultest = false,
      which_key = false,
    },
    styles = {
      comments = "italic",
      keywords = "italic",
      virtual_text = "italic,underline",
    },
    options = {
      bold = true,
      italic = true,
      underline = true,
      undercurl = true,
      cursorline = true,
      -- terminal_colors = true,
      -- transparency = true,
    },
    colors = {
      onedark = {
        vim = "#81b766", -- green
        brackets = "#abb2bf", -- fg / gray
        cursorline = "#2e323b",
        indentline = "#3c414d",

        ghost_text = "#555961",

        bufferline_text_focus = "#949aa2",

        statusline_bg = "#2e323b", -- gray

        telescope_prompt = "#2e323a",
        telescope_results = "#21252d",
      },
      onelight = {
        vim = "#029632", -- green
        brackets = "#e05661", -- red
        scrollbar = "#eeeeee",

        ghost_text = "#c3c3c3",

        statusline_bg = "#f0f0f0", -- gray

        telescope_prompt = "#f5f5f5",
        telescope_results = "#eeeeee",
      },
    },
    ft_highlights = {
      yaml = { TSField = { fg = "${red}" } },
      python = {
        TSFunction = { fg = "${blue}", style = "bold" },
      },
      -- ruby = {
      --   Hlargs = { fg = "${red}" },
      --   TSFunction = { fg = "${blue}", style = "bold" },
      --   TSInclude = { fg = "${blue}", style = "italic" },
      --   TSParameter = { fg = "${fg}", style = "italic" },
      --   TSSymbol = { fg = "${cyan}" },
      -- },
      scss = {
        -- TSFunction = { fg = "${cyan}" },
        TSProperty = { fg = "${orange}" },
        TSPunctDelimiter = { fg = "${orange}" },
        TSType = { fg = "${red}" },
      },
    },
    -- ft_highlights_force = true,
    highlights = {
      BufferlineOffset = { fg = "${purple}", style = "bold" },
      ModeMsg = { link = "LineNr" }, -- Make command line text lighter
      StatusLine = { bg = "NONE", fg = "NONE" },

      -- Ruby
      ["@function.ruby"] = { fg = "${blue}", style = "bold" },
      ["@function.call.ruby"] = { fg = "${blue}", style = "bold" },
      ["@include.ruby"] = { fg = "${blue}", style = "italic" },
      ["@parameter.ruby"] = { fg = "${fg}", style = "italic" },
      ["@symbol.ruby"] = { fg = "${cyan}" },

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
        fg = (vim.o.background == "dark" and "${green}" or "${yellow}"),
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

      TelescopeMatching = { fg = "${blue}" },
      TelescopeNormal = { bg = "${telescope_results}" },
      TelescopeSelection = { bg = "${telescope_prompt}" },

      -- Todo Comments:
      TodoTest = { fg = "${purple}" },
      TodoPerf = { fg = "${purple}" },
    },
  })
  vim.cmd("colorscheme onedarkpro")
end
return M
