local ok, onedarkpro = om.safe_require("onedarkpro")
if not ok then return end

onedarkpro.setup({
  -- caching = true,
  -- log_level = "debug",
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
    -- terminal_colors = true,
    -- transparency = true,
  },
  colors = {
    onedark = {
      comment = "#5c6370", -- Revert back to original comment colors

      vim = "#81b766", -- green
      brackets = "#abb2bf", -- fg / gray
      cursorline = "#2e323b",
      indentline = "#3c414d",

      ghost_text = "#555961",

      buffer_color = "#939aa3",
      statusline_bg = "#2e323b", -- gray

      telescope_prompt = "#2e323a",
      telescope_results = "#21252d",
    },
    onelight = {
      comment = "#bebebe", -- Revert back to original comment colors

      vim = "#029632", -- green
      brackets = "#e05661", -- red
      scrollbar = "#eeeeee",

      ghost_text = "#c3c3c3",

      buffer_color = "#6a6a6a",
      statusline_bg = "#f0f0f0", -- gray

      telescope_prompt = "#f5f5f5",
      telescope_results = "#eeeeee",
    },
  },
  highlights = {
    CursorLineNR = { bg = "${cursorline}", fg = "${purple}", style = "bold" },
    DiffChange = { style = "underline" }, -- diff mode: Changed line |diff.txt|
    MatchParen = { fg = "${cyan}", style = "underline" },
    ModeMsg = { link = "LineNr" }, -- Make command line text lighter
    Search = { bg = "${selection}", fg = "${yellow}", style = "underline" },
    TabLine = { fg = "${gray}", bg = "${bg}" },
    TabLineSel = { fg = "${bg}", bg = "${purple}" },

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

    -- Bufferline
    BufferlineVim = { fg = "${vim}" },
    BufferlineNormal = { bg = "${bg}", fg = "${gray}" },
    BufferlineSelected = { bg = "${statusline_bg}", fg = "${purple}" },
    BufferlineOffset = { fg = "${purple}", style = "bold" },

    -- Cmp
    CmpItemAbbrMatch = { fg = "${blue}", style = "bold" },
    CmpItemAbbrMatchFuzzy = { fg = "${blue}", style = "underline" },
    GhostText = { fg = "${ghost_text}" },

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

    -- Minimap
    MapBase = { fg = "${gray}" },
    MapCursor = { fg = "${purple}", bg = "${cursorline}" },
    -- MapRange = { fg = "${fg}" },

    -- Navic
    NavicText = { fg = "${gray}", style = "italic" },

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

    -- Todo Comments:
    TodoTest = { fg = "${purple}" },
    TodoPerf = { fg = "${purple}" },
  },
})

vim.cmd("colorscheme onedarkpro")
