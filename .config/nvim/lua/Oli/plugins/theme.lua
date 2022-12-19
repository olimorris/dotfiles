local ok, onedarkpro = om.safe_require("onedarkpro")
if not ok then return end

local Color = require("onedarkpro.lib.color")
local dark_colors = onedarkpro.get_colors("onedark")
local light_colors = onedarkpro.get_colors("onelight")

onedarkpro.setup({
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
      cursorline = "#2e323b",
      indentline = "#3c414d",
      buffer_color = "#939aa3",
      statusline_bg = "#2e323b", -- gray
      telescope_prompt = Color.from_hex(dark_colors.bg):darker(2):to_css(),
      telescope_results = Color.from_hex(dark_colors.bg):darker(4):to_css(),
      telescope_preview = Color.from_hex(dark_colors.bg):darker(6):to_css(),
      copilot = Color.from_hex(dark_colors.gray):darker(8):to_css(),
      breadcrumbs = Color.from_hex(dark_colors.gray):darker(10):to_css(),
    },
    light = {
      vim = "#029632", -- green
      comment = "#bebebe", -- Revert back to original comment colors
      scrollbar = "#eeeeee",
      buffer_color = "#6a6a6a",
      statusline_bg = "#f0f0f0", -- gray
      telescope_prompt = Color.from_hex(light_colors.bg):darker(2):to_css(),
      telescope_results = Color.from_hex(light_colors.bg):darker(5):to_css(),
      telescope_preview = Color.from_hex(light_colors.bg):darker(7):to_css(),
      copilot = Color.from_hex(light_colors.gray):lighter(8):to_css(),
      breadcrumbs = Color.from_hex(light_colors.gray):lighter(10):to_css(),
    },
  },
  highlights = {
    CursorLineNr = { bg = "${cursorline}", fg = "${purple}", style = "bold" },
    DiffChange = { style = "underline" }, -- diff mode: Changed line |diff.txt|
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
