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

M.cinnamon = function()
  local ok, cinnamon = om.safe_require("cinnamon")
  if not ok then
    return
  end

  cinnamon.setup()
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

M.copilot = function()
  vim.g.copilot_no_tab_map = true

  vim.g.copilot_filetypes = {
    ["*"] = true,
    TelescopePrompt = false,
    TelescopeResults = false,
    ["neo-tree-popup"] = false,
  }
end

M.coverage = function()
  local ok, coverage = om.safe_require("coverage")
  if not ok then
    return
  end

  local colors = require("onedarkpro").get_colors(vim.g.onedarkpro_style)

  coverage.setup({
    commands = false,
    highlights = {
      covered = { fg = colors.green },
      uncovered = { fg = colors.red },
    },
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

M.harpoon = function()
  local ok, harpoon = om.safe_require("harpoon")
  if not ok then
    return
  end

  harpoon.setup({
    global_settings = { save_on_toggle = true, mark_branch = true },
  })
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

M.mason = function()
  local ok, mason = om.safe_require("mason")
  if not ok then
    return
  end

  mason.setup({
    log_level = vim.log.levels.DEBUG,
    ui = {
      icons = {
        package_installed = "",
        package_pending = "",
        package_uninstalled = "",
      },
    },
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

M.nvim_navic = function()
  local ok, navic = om.safe_require("nvim-navic")
  if not ok then
    return
  end

  -- Silence errors
  vim.g.navic_silence = true

  navic.setup({
    highlight = true,
  })
end

M.nvim_surround = function()
  local ok, surround = om.safe_require("nvim-surround")
  if not ok then
    return
  end

  surround.setup()
end

M.overseer = function()
  local ok, overseer = om.safe_require("overseer")
  if not ok then
    return
  end

  return overseer.setup({
    component_aliases = {
      default_neotest = {
        "on_output_summarize",
        "on_exit_set_status",
        "on_complete_dispose",
      },
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
    silent = true,
    before_save = function()
      -- Clear out Minimap before saving the session
      -- With Minimap open it stops the session restoring to the last cursor position
      pcall(vim.cmd, "bw minimap")
    end,
    telescope = {
      before_source = function()
        vim.api.nvim_input("<ESC>:%bd!<CR>")
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
  require("telescope").load_extension("refactoring")
end

M.scrollbar = function()
  local ok, scrollbar = om.safe_require("scrollbar")
  if not ok then
    return
  end

  local colors = require("onedarkpro").get_colors(vim.g.onedarkpro_style)

  scrollbar.setup({
    max_lines = 500,
    handle = {
      color = colors.scrollbar,
    },
    marks = {
      Search = { color = colors.orange },
      Error = { color = colors.red },
      Warn = { color = colors.yellow },
      Info = { color = colors.blue },
      Hint = { color = colors.cyan },
      Misc = { color = colors.purple },
    },
  })

  local ok, hlslens = om.safe_require("hlslens")
  if ok then
    require("scrollbar.handlers.search").setup()
  end
end


M.stickybuf = function()
  local ok, stickybuf = om.safe_require("stickybuf")
  if not ok then
    return
  end

  stickybuf.setup()
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

M.textobj_diagnostic = function()
  local ok, textobj = om.safe_require("textobj-diagnostic")
  if not ok then
    return
  end

  textobj.setup({ create_default_keymaps = false })
end

M.todo_comments = function()
  local ok, todo = om.safe_require("todo-comments")
  if not ok then
    return
  end

  todo.setup({
    signs = false,
    keywords = {
      FIX = { icon = " " }, -- Custom fix icon
      PERF = { color = "perf" },
    },
    colors = {
      perf = { "TodoTest" },
      test = { "TodoTest" },
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
