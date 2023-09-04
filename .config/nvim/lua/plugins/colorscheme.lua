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
      colors = {
        dark = {
          statusline_bg = "#2e323b", -- gray
          statuscolumn_border = "#4b5160", -- gray
          ellipsis = "#808080", -- gray
          telescope_prompt = "require('onedarkpro.helpers').darken('bg', 1, 'onedark')",
          telescope_results = "require('onedarkpro.helpers').darken('bg', 4, 'onedark')",
          telescope_preview = "require('onedarkpro.helpers').darken('bg', 6, 'onedark')",
          telescope_selection = "require('onedarkpro.helpers').darken('bg', 8, 'onedark')",
          copilot = "require('onedarkpro.helpers').darken('gray', 8, 'onedark')",
          breadcrumbs = "require('onedarkpro.helpers').darken('gray', 10, 'onedark')",
          local_highlight = "require('onedarkpro.helpers').lighten('bg', 4, 'onedark')",
          light_gray = "require('onedarkpro.helpers').darken('gray', 7, 'onedark')",
        },
        light = {
          comment = "#bebebe", -- Revert back to original comment colors
          statusline_bg = "#f0f0f0", -- gray
          statuscolumn_border = "#e7e7e7", -- gray
          ellipsis = "#808080", -- gray
          git_add = "require('onedarkpro.helpers').get_preloaded_colors('onelight').green",
          git_change = "require('onedarkpro.helpers').get_preloaded_colors('onelight').yellow",
          git_delete = "require('onedarkpro.helpers').get_preloaded_colors('onelight').red",
          telescope_prompt = "require('onedarkpro.helpers').darken('bg', 2, 'onelight')",
          telescope_results = "require('onedarkpro.helpers').darken('bg', 5, 'onelight')",
          telescope_preview = "require('onedarkpro.helpers').darken('bg', 7, 'onelight')",
          telescope_selection = "require('onedarkpro.helpers').darken('bg', 9, 'onelight')",
          copilot = "require('onedarkpro.helpers').lighten('gray', 8, 'onelight')",
          breadcrumbs = "require('onedarkpro.helpers').lighten('gray', 8, 'onelight')",
          local_highlight = "require('onedarkpro.helpers').darken('bg', 5, 'onelight')",
          light_gray = "require('onedarkpro.helpers').lighten('gray', 10, 'onelight')",
        },
      },
      highlights = {
        EdgyNormal = { bg = "${bg}" },
        EdgyTitle = { fg = "${purple}", bold = true },

        NormalFloat = { bg = "${bg}" }, -- Set the terminal background to be the same as the editor
        FloatBorder = { fg = "${gray}", bg = "${bg}" },

        LspLens = { fg = "${light_gray}", italic = true },
        CursorLineNr = { bg = "${bg}", fg = "${fg}" },
        DiffChange = { underline = true }, -- diff mode: Changed line |diff.txt|
        LocalHighlight = { bg = "${local_highlight}" },
        MatchParen = { fg = "${cyan}" },
        ModeMsg = { fg = "${gray}" }, -- Make command line text lighter
        Search = { bg = "${selection}", fg = "${yellow}", underline = true },
        VimLogo = { fg = { dark = "#81b766", light = "#029632" } },

        TabLine = { fg = "${gray}", bg = "${bg}" },
        TabLineSel = { fg = "${bg}", bg = "${purple}" },

        -- Treesitter plugin
        ["@text.todo.checked"] = { fg = "${bg}", bg = "${purple}" },

        -- Aerial plugin
        AerialClass = { fg = "${purple}", bold = true, italic = true },
        AerialClassIcon = { fg = "${purple}" },
        AerialConstructorIcon = { fg = "${yellow}" },
        AerialEnumIcon = { fg = "${blue}" },
        AerialFunctionIcon = { fg = "${red}" },
        AerialInterfaceIcon = { fg = "${orange}" },
        AerialMethodIcon = { fg = "${green}" },
        AerialStructIcon = { fg = "${cyan}" },

        -- Alpha
        AlphaHeader = {
          fg = { dark = "${green}", light = "${red}" },
        },
        AlphaButtonText = {
          fg = "${blue}",
          bold = true,
        },
        AlphaButtonShortcut = {
          fg = { dark = "${green}", light = "${yellow}" },
          italic = true,
        },
        AlphaFooter = { fg = "${gray}", italic = true },

        -- Bufferline
        BufferlineNormal = { bg = "${bg}", fg = "${gray}" },
        BufferlineSelected = { bg = "${statusline_bg}", fg = "${purple}" },
        BufferlineOffset = { fg = "${purple}", bold = true },

        -- ChatGPT
        ChatGPTWindow = { bg = "${float_bg}", fg = "${fg}" },
        ChatGPTPrompt = { bg = "${float_bg}", fg = "${fg}" },
        ChatGPTQuestion = { fg = "${blue}", italic = true },
        ChatGPTTotalTokens = { fg = "${bg}", bg = "${gray}" },
        ChatGPTTotalTokensBorder = { fg = "${gray}" },

        -- Cmp
        CmpItemAbbrMatch = { fg = "${blue}", bold = true },
        CmpItemAbbrMatchFuzzy = { fg = "${blue}", underline = true },

        -- Copilot
        CopilotSuggestion = { fg = "${copilot}", italic = true },

        -- DAP
        DebugBreakpoint = { fg = "${red}", bold = true },
        DebugHighlightLine = { fg = "${purple}", italic = true },
        NvimDapVirtualText = { fg = "${cyan}", italic = true },

        -- DAP UI
        DapUIBreakpointsCurrentLine = { fg = "${yellow}", bold = true },

        -- Diagflow.nvim
        DiagnosticFloatingError = { fg = "${red}", italic = true },
        DiagnosticFloatingWarn = { fg = "${yellow}", italic = true },
        DiagnosticFloatingHint = { fg = "${cyan}", italic = true },
        DiagnosticFloatingInfo = { fg = "${blue}", italic = true },

        -- Fidget
        FidgetTask = { fg = "${gray}" },
        FidgetTitle = { fg = "${purple}", italic = true },

        -- Heirline
        Heirline = { bg = "${statusline_bg}" },
        HeirlineStatusColumn = { fg = "${statuscolumn_border}" },
        HeirlineBufferline = { fg = { dark = "#939aa3", light = "#6a6a6a" } },

        -- Luasnip
        LuaSnipChoiceNode = { fg = "${yellow}" },
        LuaSnipInsertNode = { fg = "${yellow}" },

        -- Navic
        NavicText = { fg = "${breadcrumbs}", italic = true },

        -- Neotest
        NeotestAdapterName = { fg = "${purple}", bold = true },
        NeotestFocused = { bold = true },
        NeotestNamespace = { fg = "${blue}", bold = true },

        -- Neotree
        NeoTreeRootName = { fg = "${purple}", bold = true },
        NeoTreeFileNameOpened = { fg = "${purple}", italic = true },

        -- Nvim UFO
        UfoFoldedEllipsis = { fg = "${ellipsis}" },

        -- Satellite
        ScrollView = { bg = "${gray}" },
        SatelliteCursor = { fg = "${red}" },

        -- Telescope
        TelescopeBorder = {
          fg = "${telescope_results}",
          bg = "${telescope_results}",
        },
        TelescopePromptPrefix = {
          fg = "${purple}",
        },
        TelescopePromptBorder = {
          fg = "${telescope_prompt}",
          bg = "${telescope_prompt}",
        },
        TelescopePromptCounter = { fg = "${fg}" },
        TelescopePromptNormal = { fg = "${fg}", bg = "${telescope_prompt}" },
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

        -- Virt Column
        VirtColumn = { fg = "${indentline}" },
      },

      -- caching = false,
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
