local M = {
  dir = "~/Code/Projects/onedarkpro.nvim",
  priority = 1000,
  name = "onedarkpro",
}

function M.config()
  require("legendary").commands({
    {
      ":OnedarkproCache",
      description = "Cache the theme",
    },
    {
      ":OnedarkproClean",
      description = "Clean the theme cache",
    },
    {
      ":OnedarkproColors",
      description = "Show the theme's colors",
    },
  })

  require("onedarkpro").setup({
    cache_path = vim.fn.expand(vim.fn.stdpath("cache") .. "/onedarkpro_dotfiles"),
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
      conditionals = "italic",
      keywords = "italic",
      virtual_text = "italic",
    },
    options = {
      cursorline = true,
      -- transparency = true,
      -- highlight_inactive_windows = true,
    },
    colors = {
      dark = {
        vim = "#81b766", -- green
        comment = "#5c6370", -- Revert back to original comment colors
        cmp_menu = "require('onedarkpro.helpers').darken('onedark', 'bg', 5)",
        cmp_cursorline = "require('onedarkpro.helpers').darken('onedark', 'bg', 8)",
        cursorline = "#2e323b",
        indentline = "#3c414d",
        buffer_color = "#939aa3",
        statusline_bg = "#2e323b", -- gray
        telescope_prompt = "require('onedarkpro.helpers').darken('onedark', 'bg', 1)",
        telescope_results = "require('onedarkpro.helpers').darken('onedark', 'bg', 4)",
        telescope_preview = "require('onedarkpro.helpers').darken('onedark', 'bg', 6)",
        copilot = "require('onedarkpro.helpers').darken('onedark', 'gray', 8)",
        breadcrumbs = "require('onedarkpro.helpers').darken('onedark', 'gray', 10)",
      },
      light = {
        vim = "#029632", -- green
        cmp_menu = "require('onedarkpro.helpers').darken('onelight', 'bg', 4)",
        cmp_cursorline = "require('onedarkpro.helpers').darken('onelight', 'bg', 8)",
        comment = "#bebebe", -- Revert back to original comment colors
        scrollbar = "#eeeeee",
        buffer_color = "#6a6a6a",
        statusline_bg = "#f0f0f0", -- gray
        telescope_prompt = "require('onedarkpro.helpers').darken('onelight', 'bg', 2)",
        telescope_results = "require('onedarkpro.helpers').darken('onelight', 'bg', 5)",
        telescope_preview = "require('onedarkpro.helpers').darken('onelight', 'bg', 7)",
        copilot = "require('onedarkpro.helpers').lighten('onelight', 'gray', 8)",
        breadcrumbs = "require('onedarkpro.helpers').lighten('onelight', 'gray', 8)",
      },
    },
    highlights = {
      CursorLineNr = { bg = "${cursorline}", fg = "${purple}", style = "bold" },
      DiffChange = { style = "underline" }, -- diff mode: Changed line |diff.txt|
      CmpMenu = { bg = "${cmp_menu}" },
      CmpCursorLine = { bg = "${cmp_cursorline}" },
      MatchParen = { fg = "${cyan}" },
      ModeMsg = { link = "LineNr" }, -- Make command line text lighter
      Search = { bg = "${selection}", fg = "${yellow}", style = "underline" },
      TabLine = { fg = "${gray}", bg = "${bg}" },
      TabLineSel = { fg = "${bg}", bg = "${purple}" },

      -- Treesitter plugin
      ["@text.todo.checked"] = { fg = "${bg}", bg = "${purple}" },

      -- Aerial plugin
      AerialClass = { fg = "${purple}", style = "bold,italic" },
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

      --Barbecue
      BarbecueModified = { fg = "${red}" },
      BarbecueEllipsis = { fg = "${breadcrumbs}", style = "italic" },
      BarbecueSeparator = { fg = "${breadcrumbs}", style = "italic" },
      BarbecueDirname = { fg = "${breadcrumbs}", style = "italic" },
      BarbecueBasename = { fg = "${breadcrumbs}", style = "italic" },
      BarbecueContext = { fg = "${breadcrumbs}", style = "italic" },

      -- Bufferline
      BufferlineVim = { fg = "${vim}" },
      BufferlineNormal = { bg = "${bg}", fg = "${gray}" },
      BufferlineSelected = { bg = "${statusline_bg}", fg = "${purple}" },
      BufferlineOffset = { fg = "${purple}", style = "bold" },

      -- ChatGPT
      ChatGPTWindow = { bg = "${float_bg}", fg = "${gray}" },
      ChatGPTPrompt = { bg = "${float_bg}", fg = "${gray}" },

      -- Cmp
      CmpItemAbbrMatch = { fg = "${blue}", style = "bold" },
      CmpItemAbbrMatchFuzzy = { fg = "${blue}", style = "underline" },

      -- Copilot
      CopilotSuggestion = { fg = "${copilot}", style = "italic" },

      -- DAP
      DebugBreakpointLine = { fg = "${red}", style = "underline" },
      DebugHighlightLine = { fg = "${purple}", style = "italic" },
      NvimDapVirtualText = { fg = "${cyan}", style = "italic" },

      -- DAP UI
      DapUIBreakpointsCurrentLine = { fg = "${yellow}", style = "bold" },

      -- Fidget
      FidgetTask = { fg = "${gray}" },
      FidgetTitle = { fg = "${purple}", style = "italic" },

      -- Heirline
      Heirline = { bg = "${statusline_bg}" },
      HeirlineBufferline = { fg = "${buffer_color}" },

      -- Luasnip
      LuaSnipChoiceNode = { fg = "${yellow}" },
      LuaSnipInsertNode = { fg = "${yellow}" },

      -- Neotest
      NeotestAdapterName = { fg = "${purple}", style = "bold" },
      NeotestFocused = { style = "bold" },
      NeotestNamespace = { fg = "${blue}", style = "bold" },

      -- Neotree
      NeoTreeRootName = { fg = "${purple}", style = "bold" },
      NeoTreeFileNameOpened = { fg = "${purple}", style = "italic" },

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

      TelescopePreviewNormal = { bg = "${telescope_preview}" },
      TelescopePreviewBorder = { fg = "${telescope_preview}", bg = "${telescope_preview}" },

      -- Todo Comments
      TodoTest = { fg = "${purple}" },
      TodoPerf = { fg = "${purple}" },
    },
  })

  if vim.o.background == "light" then
    vim.cmd([[colorscheme onelight]])
  else
    vim.cmd([[colorscheme onedark]])
  end
end

return M
