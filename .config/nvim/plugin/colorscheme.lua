require("onedarkpro").setup({
  colors = {
    vaporwave = {
      breadcrumbs = "require('onedarkpro.helpers').darken('gray', 10, 'vaporwave')",
      codeblock = "require('onedarkpro.helpers').lighten('bg', 2, 'vaporwave')",
      copilot = "require('onedarkpro.helpers').darken('gray', 8, 'vaporwave')",
      picker_results = "require('onedarkpro.helpers').darken('bg', 4, 'vaporwave')",
      picker_selection = "require('onedarkpro.helpers').darken('bg', 8, 'vaporwave')",
      statusline_fill = "require('onedarkpro.helpers').lighten('bg', 2, 'vaporwave')",
    },
    onedark = {
      breadcrumbs = "require('onedarkpro.helpers').darken('gray', 10, 'onedark')",
      codeblock = "require('onedarkpro.helpers').lighten('bg', 2, 'onedark')",
      copilot = "require('onedarkpro.helpers').darken('gray', 8, 'onedark')",
      picker_results = "require('onedarkpro.helpers').darken('bg', 4, 'onedark')",
      picker_selection = "require('onedarkpro.helpers').darken('bg', 8, 'onedark')",
      statusline_fill = "require('onedarkpro.helpers').lighten('bg', 2, 'onedark')",
    },
    light = {
      breadcrumbs = "require('onedarkpro.helpers').lighten('gray', 8, 'onelight')",
      codeblock = "require('onedarkpro.helpers').darken('bg', 3, 'onelight')",
      comment = "#bebebe",
      copilot = "require('onedarkpro.helpers').lighten('gray', 8, 'onelight')",
      git_add = "require('onedarkpro.helpers').get_preloaded_colors('onelight').green",
      git_change = "require('onedarkpro.helpers').get_preloaded_colors('onelight').yellow",
      git_delete = "require('onedarkpro.helpers').get_preloaded_colors('onelight').red",
      picker_results = "require('onedarkpro.helpers').darken('bg', 5, 'onelight')",
      picker_selection = "require('onedarkpro.helpers').darken('bg', 9, 'onelight')",
      statusline_fill = "require('onedarkpro.helpers').darken('bg', 2, 'onelight')",
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
    CodeCompanionCodeReviewComment = { fg = "${cyan}", italic = true },

    ["@markup.raw.block.markdown"] = { bg = "${codeblock}" },
    ["@markup.quote.markdown"] = { italic = true, extend = true },

    NormalFloat = { bg = "${bg}" }, -- Set the terminal background to be the same as the editor
    FloatBorder = { fg = "${gray}", bg = "${bg}" },

    CursorLineNr = { bg = "${bg}", fg = "${fg}", italic = true },
    MatchParen = { fg = "${cyan}" },
    ModeMsg = { fg = "${gray}" }, -- Make command line text lighter
    Search = { bg = "${selection}", fg = "${yellow}", underline = true },
    VimLogo = { fg = { dark = "#81b766", light = "#029632" } },

    -- Dashboard
    SnacksDashboardDesc = { fg = "${blue}", bold = true },
    SnacksDashboardKey = { fg = "${purple}", bold = true },
    SnacksDashboardCommand = { fg = "${orange}" },

    -- Copilot
    CopilotSuggestion = { fg = "${copilot}", italic = true },

    -- DAP
    DebugBreakpoint = { fg = "${red}", italic = true },
    DebugHighlightLine = { fg = "${purple}", italic = true },
    NvimDapVirtualText = { fg = "${cyan}", italic = true },

    -- DAP UI
    DapUIBreakpointsCurrentLine = { fg = "${yellow}", bold = true },

    -- Statusline
    StatusLine = { fg = "${gray}", bg = "${statusline_fill}" },
    StatusLineNC = { fg = "${gray}", bg = "${statusline_fill}" },

    -- Mode names come from MiniStatusline.section_mode, which has no separate
    -- select or terminal group: select falls under visual, terminal under other
    MiniStatuslineModeNormal = { fg = "${bg}", bg = "${purple}", bold = true },
    MiniStatuslineModeInsert = { fg = "${bg}", bg = "${green}", bold = true },
    MiniStatuslineModeVisual = { fg = "${bg}", bg = "${orange}", bold = true },
    MiniStatuslineModeReplace = { fg = "${bg}", bg = "${green}", bold = true },
    MiniStatuslineModeCommand = { fg = "${bg}", bg = "${orange}", bold = true },
    MiniStatuslineModeOther = { fg = "${bg}", bg = "${red}", bold = true },

    StatuslineBlock = { fg = "${gray}", bg = "${statusline_fill}" },
    StatuslineBlockAhead = { fg = "${green}", bg = "${statusline_fill}" },
    StatuslineBlockBehind = { fg = "${red}", bg = "${statusline_fill}" },

    StatuslineText = { fg = "${gray}", bg = "${statusline_fill}" },
    StatuslineRequest = { fg = "${yellow}", bg = "${statusline_fill}" },
    StatuslineApproval = { fg = "${red}", bg = "${statusline_fill}" },

    StatuslineMacro = { fg = "${bg}", bg = "${blue}" },
    StatuslineSearch = { fg = "${bg}", bg = "${yellow}" },
    StatuslineRuler = { fg = "${bg}", bg = "${gray}", bold = true },

    -- Winbar
    WinbarPath = { fg = "${breadcrumbs}", italic = true },
    WinbarFile = { fg = "${fg}", italic = true },
    WinbarSymbol = { link = "Comment" },
    WinbarModified = { fg = "${red}" },
    WinbarReadonly = { fg = "${blue}" },

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
end

vim.api.nvim_create_autocmd("VimEnter", {
  nested = true,
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
