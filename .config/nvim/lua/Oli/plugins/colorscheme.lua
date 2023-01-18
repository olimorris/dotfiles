return {
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000,
    init = function()
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
    end,
    opts = {
      caching = false,
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
      colors = {
        dark = {
          statusline_bg = "#2e323b", -- gray
          statuscolumn_border = "#3c4047",
          indentline = "#3c4047",
          telescope_prompt = "require('onedarkpro.helpers').darken('bg', 1, 'onedark')",
          telescope_results = "require('onedarkpro.helpers').darken('bg', 4, 'onedark')",
          telescope_preview = "require('onedarkpro.helpers').darken('bg', 6, 'onedark')",
          telescope_selection = "require('onedarkpro.helpers').darken('bg', 8, 'onedark')",
          copilot = "require('onedarkpro.helpers').darken('gray', 8, 'onedark')",
          breadcrumbs = "require('onedarkpro.helpers').darken('gray', 10, 'onedark')",
        },
        light = {
          comment = "#bebebe", -- Revert back to original comment colors
          statusline_bg = "#f0f0f0", -- gray
          statuscolumn_border = "require('onedarkpro.helpers').darken('bg', 3, 'onelight')",
          telescope_prompt = "require('onedarkpro.helpers').darken('bg', 2, 'onelight')",
          telescope_results = "require('onedarkpro.helpers').darken('bg', 5, 'onelight')",
          telescope_preview = "require('onedarkpro.helpers').darken('bg', 7, 'onelight')",
          telescope_selection = "require('onedarkpro.helpers').darken('bg', 9, 'onelight')",
          copilot = "require('onedarkpro.helpers').lighten('gray', 8, 'onelight')",
          breadcrumbs = "require('onedarkpro.helpers').lighten('gray', 8, 'onelight')",
        },
      },
      highlights = {
        CursorLine = { bg = "NONE" },
        DiffChange = { style = "underline" }, -- diff mode: Changed line |diff.txt|
        MatchParen = { fg = "${cyan}" },
        ModeMsg = { fg = "${gray}" }, -- Make command line text lighter
        Search = { bg = "${selection}", fg = "${yellow}", style = "underline" },

        FoldColumn = { bg = "${bg}" },
        SignColumn = { bg = "${bg}" },
        LineNr = { bg = "${bg}", fg = "${gray}" },
        CursorLineNr = { bg = "${bg}", fg = "${purple}", style = "bold" },

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
          fg = { dark = "${green}", light = "${red}" },
        },
        AlphaButtonText = {
          fg = "${blue}",
          style = "bold",
        },
        AlphaButtonShortcut = {
          fg = { dark = "${green}", light = "${yellow}" },
          style = "italic",
        },
        AlphaFooter = { fg = "${gray}", style = "italic" },

        -- Bufferline
        BufferlineVim = { fg = { dark = "#81b766", light = "#029632" } },
        BufferlineNormal = { bg = "${bg}", fg = "${gray}" },
        BufferlineSelected = { bg = "${statusline_bg}", fg = "${purple}" },
        BufferlineOffset = { fg = "${purple}", style = "bold" },

        -- ChatGPT
        ChatGPTWindow = { bg = "${float_bg}", fg = "${fg}" },
        ChatGPTPrompt = { bg = "${float_bg}", fg = "${fg}" },
        ChatGPTQuestion = { fg = "${blue}", style = "italic" },
        ChatGPTTotalTokens = { fg = "${bg}", bg = "${gray}" },
        ChatGPTTotalTokensBorder = { fg = "${gray}" },

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

        -- Gitsigns
        GitSignsAdd = { fg = { dark = "#45966c", light = "#c5e6c7" } },
        GitSignsChange = { fg = { dark = "#928b65", light = "#eadcb5" } },
        GitSignsDelete = { fg = { dark = "#8e3c40", light = "#f9cfce" } },

        -- Heirline
        Heirline = { bg = "${statusline_bg}" },
        HeirlineBufferline = { fg = { dark = "#939aa3", light = "#6a6a6a" } },

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
        TelescopeSelection = { bg = "${telescope_selection}" },
        TelescopePreviewNormal = { bg = "${telescope_preview}" },
        TelescopePreviewBorder = { fg = "${telescope_preview}", bg = "${telescope_preview}" },
      },
    },
    config = function(_, opts)
      require("onedarkpro").setup(opts)

      if vim.o.background == "light" then
        vim.cmd([[colorscheme onelight]])
      else
        vim.cmd([[colorscheme onedark]])
      end
    end,
  },
}
