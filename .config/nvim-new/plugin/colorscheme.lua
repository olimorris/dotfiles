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
    SnacksDashboardFooterText = { fg = "${green}" },
    SnacksDashboardFooterEmphasis = { fg = "${blue}" },
    SnacksDashboardFooterVersion = { fg = "${gray}" },

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
    SnacksPickerTree = { bg = "${picker_results}" },
    SnacksPickerToggle = { bg = "${purple}", fg = "${picker_results}", italic = true },
    SnacksPickerTotals = { bg = "${picker_results}", fg = "${purple}", bold = true },
    SnacksPickerUnselected = { bg = "${picker_results}" },

    SnacksPickerPreview = { bg = "${bg}" },
    SnacksPickerPreviewBorder = { fg = "${bg}", bg = "${bg}" },
    SnacksPickerPreviewTitle = { bg = "${green}", fg = "${bg}", bold = true },
  },

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

---Toggle between themes
---@param mode? "dark" | "light" | nil
---@return nil
function om.ToggleTheme(mode)
  local themes = {
    dark = "vaporwave",
    light = "onelight",
  }

  ---Change the theme
  ---@param m "dark" | "light" The mode to set
  ---@param t string The theme to use
  ---@return nil
  local function change_theme(m, t)
    vim.cmd("set background=" .. m)
    vim.cmd("colorscheme " .. t)
  end

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

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if not om.ToggleTheme then
      return
    end

    local uv = vim.uv
    local file_to_watch = "/tmp/oli-theme"
    local flags = { watch_entry = false, stat = false, recursive = false }
    local function read_file(file)
      local fd = uv.fs_open(file, "r", 438)
      if not fd then
        return nil
      end
      local stat = uv.fs_fstat(fd)
      local data = stat and uv.fs_read(fd, stat.size, 0) or nil
      uv.fs_close(fd)
      return data and vim.trim(data) or nil
    end
    local function set_theme()
      local ok, theme = pcall(read_file, file_to_watch)
      if ok and (theme == "dark" or theme == "light") then
        om.ToggleTheme(theme)
      else
        om.ToggleTheme(vim.o.background)
      end
    end
    local event_cb = function(err, filename, _)
      if not err and filename and uv.fs_stat(file_to_watch) then
        vim.schedule(function()
          set_theme()
        end)
      end
    end
    set_theme()
    uv.fs_event_start(uv.new_fs_event(), file_to_watch, flags, event_cb)
  end,
})
