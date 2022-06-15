local M = {}

local filetypes_to_exclude = {
  "aerial",
  "alpha",
  "help",
  "gitcommit",
  "dashboard",
  "neo-tree",
  "NvimTree",
  "packer",
  "lspinfo",
  "Startify",
  "TelescopePrompt",
  "TelescopeResults",
  "terminal",
  "Trouble",
  "undotree",
  "",
}

M.aerial = function()
  local ok, aerial = om.safe_require("aerial")
  if not ok then
    return
  end

  aerial.setup({
    backends = {
      -- default to preferring LSP backend
      ["_"] = { "lsp", "treesitter", "markdown" },
      ruby = { "treesitter" },
    },
    close_on_select = true,
    default_direction = "prefer_right",
    min_width = 30,
  })
end

M.colorizer = function()
  local ok, colorizer = om.safe_require("colorizer")
  if not ok then
    return
  end

  colorizer.setup({
    "css",
    eruby = { mode = "foreground" },
    html = { mode = "foreground" },
    "lua",
    "javascript",
    "vue",
  })
end

M.comment = function()
  local ok, comment = om.safe_require("Comment")
  if not ok then
    return
  end

  comment.setup({
    padding = true, -- Add a space to commented line
  })
end

M.dap = function()
  local ok, dap = om.safe_require("dap")
  if not ok then
    return
  end

  -- dap.set_log_level("TRACE")

  vim.fn.sign_define("DapBreakpoint", {
    text = "",
    texthl = "DebugBreakpoint",
    linehl = "",
    numhl = "DebugBreakpoint",
  })
  vim.fn.sign_define("DapStopped", {
    text = "",
    texthl = "DebugHighlight",
    linehl = "",
    numhl = "DebugHighlight",
  })
end

M.dap_ui = function()
  local ok, dap_ui = om.safe_require("dapui")
  if not ok then
    print("No Dap UI")
    return
  end

  dap_ui.setup({
    sidebar = {
      elements = {
        -- You can change the order of elements in the sidebar
        { id = "scopes", size = 0.4 },
        { id = "stacks", size = 0.2 },
        { id = "breakpoints", size = 0.2 },
        { id = "watches", size = 0.2 },
      },
      size = 40,
    },
    tray = { size = 10 },
  })
end

M.dressing = function()
  local ok, dressing = om.safe_require("dressing")
  if not ok then
    return
  end

  dressing.setup({
    input = { default_prompt = "> ", winblend = 0 },
    select = { backend = "telescope" },
  })
end

M.fidget = function()
  local ok, fidget = om.safe_require("fidget")
  if not ok then
    return
  end

  fidget.setup({
    text = {
      spinner = "line",
      done = "",
    },
    window = {
      blend = 0,
    },
  })
end

M.gps = function()
  local ok, gps = om.safe_require("nvim-gps")
  if not ok then
    return
  end

  vim.g.enable_gps = false

  gps.setup({
    disable_icons = false,
    depth = 2,
  })
end

M.hlargs = function()
  local ok, hlargs = om.safe_require("hlargs")
  if not ok then
    return
  end

  hlargs.setup({
    paint_arg_declarations = false,
  })
end

M.harpoon = function()
  local ok, harpoon = om.safe_require("harpoon")
  if not ok then
    return
  end

  harpoon.setup({
    global_settings = { save_on_toggle = true, mark_branch = true },
  })
end

M.headlines = function()
  local ok, headlines = om.safe_require("headlines")
  if not ok then
    return
  end

  headlines.setup()
end

M.hop = function()
  local ok, hop = om.safe_require("hop")
  if not ok then
    return
  end

  -- remove h,j,k,l from hop's list of keys
  hop.setup({ keys = "etovxqpdygfbzcisuran" })
end

M.indentline = function()
  local ok, indentline = om.safe_require("indent_blankline")
  if not ok then
    return
  end

  indentline.setup({
    use_treesitter = true,
    show_first_indent_level = false,
    show_trailing_blankline_indent = false,

    filetype_exclude = filetypes_to_exclude,
    buftype_exclude = { "terminal", "nofile" },
  })
end

M.minimap = function()
  vim.g.minimap_auto_start = 0
  vim.g.minimap_width = 15
  vim.g.minimap_highlight_range = 1
  vim.g.minimap_base_highlight = "MapBase"
  vim.g.minimap_cursor_color = "MapCursor"
  vim.g.minimap_range_color = "MapRange"
  vim.g.minimap_close_filetypes = { "alpha", "NvimTree", "toggleterm" }
end

M.neogen = function()
  local ok, neogen = om.safe_require("neogen")
  if not ok then
    return
  end

  neogen.setup({
    snippet_engine = "luasnip",
  })
end

M.nvim_autopairs = function()
  local ok, autopairs = om.safe_require("nvim-autopairs")
  if not ok then
    return
  end

  autopairs.setup({
    close_triple_quotes = true,
    check_ts = true,
    fast_wrap = {
      map = "<c-e>",
    },
  })
end
M.persisted = function()
  local ok, persisted = om.safe_require("persisted")
  if not ok then
    return
  end

  persisted.setup({
    save_dir = Sessiondir .. "/",
    use_git_branch = true,
    before_save = function()
      -- Clear out Minimap before saving the session
      -- With Minimap open it stops the session restoring to the last cursor position
      pcall(vim.cmd, "bw minimap")
    end,
    telescope = {
      before_source = function()
        persisted.stop()
      end,
    },
  })
end

M.project_nvim = function()
  local ok, project = om.safe_require("project_nvim")
  if not ok then
    return
  end

  project.setup({
    detection_methods = { "lsp", "pattern" }, -- Use the native LSP an the pattern method to detect directory
    ignore_lsp = { "efm" },
    patterns = {
      ".git",
      "_darcs",
      ".hg",
      ".bzr",
      ".svn",
      "Makefile",
      "package.json",
      "Gemfile",
    },
  })
end

M.refactoring = function()
  local ok, refactoring = om.safe_require("refactoring")
  if not ok then
    return
  end
  refactoring.setup({})
end

M.qf_helper = function()
  local ok, qf_helper = om.safe_require("qf_helper")
  if not ok then
    return
  end

  qf_helper.setup({
    quickfix = {
      max_height = 10, -- Max qf height when using open() or toggle()
      min_height = 5, -- Min qf height when using open() or toggle()
    },
    loclist = { -- The same options, but for the loclist
      max_height = 10,
      min_height = 5,
    },
  })
end

M.search = function()
  local ok, search = om.safe_require("searchbox")
  if not ok then
    return
  end

  search.setup({
    hooks = {
      before_mount = function(input)
        pcall(vim.cmd, "MinimapClose")
      end,
    },
  })
end

M.tabout = function()
  local ok, tabout = om.safe_require("tabout")
  if not ok then
    return
  end

  tabout.setup({
    tabkey = "<Tab>", -- key to trigger tabout, set to an empty string to disable
    backwards_tabkey = "<S-Tab>", -- key to trigger backwards tabout, set to an empty string to disable
    completion = true, -- We use tab for completion so set this to true
  })
end

M.todo_comments = function()
  local ok, todo = om.safe_require("todo-comments")
  if not ok then
    return
  end

  todo.setup({
    signs = false,
    keywords = {
      FIX = { icon = " ", color = "error" }, -- Custom fix icon
    },
  })
end

M.toggleterm = function()
  local ok, toggleterm = om.safe_require("toggleterm")
  if not ok then
    return
  end

  toggleterm.setup({
    direction = "float",
    float_opts = {
      border = "single",
      height = function()
        return math.floor(0.9 * vim.fn.winheight("%"))
      end,
      -- width = function()
      --   return math.floor(0.9 * vim.fn.winwidth("%"))
      -- end,
      highlights = {
        background = "ToggleTerm",
        border = "ToggleTermBorder",
      },
    },
    -- direction = "horizontal",
    -- size = 8,
    -- shade_terminals = true,
    shading_factor = 3, -- Match our background
    hide_numbers = true,
    close_on_exit = true,
    start_in_insert = true,
  })
end

M.undotree = function()
  vim.g.undotree_SplitWidth = 35
  vim.g.undotree_DiffpanelHeight = 7
  vim.g.undotree_WindowLayout = 2 -- Tree on the left, diff on the bottom
  vim.g.undotree_TreeNodeShape = "◉"
  vim.g.undotree_SetFocusWhenToggle = 1
end

M.visual_multi = function()
  vim.g.VM_silent_exit = 1
  vim.g.VM_show_warnings = 0
  vim.g.VM_set_statusline = 0
  vim.g.VM_highlight_matches = "" -- Empty string defaults to 'Search' highlight group
  vim.g.VM_quit_after_leaving_insert_mode = 1 -- Don't have to press <esc> twice

  vim.g.VM_Mono_hl = "DiffText" -- The highlight in cursor mode
  vim.g.VM_Extend_hl = "IncSearch" -- In extend mode, the selections
  vim.g.VM_Cursor_hl = "Visual" -- In extend mode, the cursors
  vim.g.VM_Insert_hl = "DiffAdd" -- In insert mode, the virtual cursors
end

M.yabs = function()
  local ok, yabs = om.safe_require("yabs")
  if not ok then
    return
  end

  yabs:setup({
    languages = {
      ruby = {
        default_task = "run",
        tasks = { run = { command = "ruby %", output = "quickfix" } },
      },
      lua = {
        default_task = "run",
        tasks = { run = { command = "make", output = "terminal" } },
      },
    },
  })
end

return M
