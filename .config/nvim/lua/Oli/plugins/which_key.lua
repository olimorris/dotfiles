local ok, wk = om.safe_require("which-key")

if not ok then
  return
end

wk.setup({
  icons = { breadcrumb = "➜" },
  plugins = { marks = false },
  presets = {
    operators = false, -- adds help for operators like d, y, ... and registers them for motion / text object completion
    motions = false,
    text_objects = false,
    windows = false,
    nav = false,
  },
  ignore_missing = true, -- do not show commands with no label
  show_help = false, -- hide the help message on the command line
})

wk.register({
  ["<C-n>"] = "New buffer",
  ["<C-y>"] = "Yank the whole buffer",
  ["<C-t>"] = "Show tags",
  ["<C-p>"] = "Telescope: Find files",
  ["<C-f>"] = "Telescope: Find in current buffer",
  ["<C-g>"] = "Telescope: Find in open buffers",
  ["<C-s>"] = "Save current buffer",
  ["<C-r>"] = "Redo",
  ["\\"] = "Toggle NvimTree",
  ["cn"] = "Multipe cursors: Replace word",
  T = "Lsp diagnostics",
  [vim.g.mapleader] = {
    [vim.g.mapleader] = "Telescope: Frequent files",
    c = "Telescope: Search todo comments",
    e = "Telescope: Edit config",
    g = "Telescope: Global search",
    h = "Clear highlights",
    l = "Location List toggle",
    p = "Telescope: Browse project files",
    r = "Reload Neovim config",
    q = "Quickfix toggle",
    ["qa"] = "Quit Neovim",
    s = "Start/restore a session",
    t = "Test nearest",
    ["1"] = "Switch a buffer with another with index 1",
    -- t = {
    -- 	name = "Tabs",
    -- 	c = "Close",
    -- 	o = "Close all but the current one",
    -- 	e = "Open a new tab",
    -- },
  },
  [vim.g.maplocalleader] = {
    a = {
      name = "OpenAI",
      a = "Suggest an alteration",
      c = "Complete",
      d = "Generate a docstring",
    },
    d = "Run/Build current file",
    f = "Search and replace",
    h = {
      name = "Harpoon",
      a = "Add file as mark",
      l = "List marks",
      ["1"] = "Navigate to mark #1",
      ["2"] = "Navigate to mark #2",
      ["3"] = "Navigate to mark #3",
      ["4"] = "Navigate to mark #4",
      ["5"] = "Navigate to mark #5",
    },
    l = { name = "LSP" }, -- Actions are registered in core.mappings.lsp()
    m = "Toggle Minimap",
    n = "Toggle line numbers",
    p = "Neoclip",
    r = "Replace words",
    s = {
      name = "Splits",
      h = "Left",
      j = "Down",
      k = "Up",
      l = "Right",
      s = "Split nicely",
      c = "Close current split",
      o = "Close all splits except the current one",
    },
    t = { name = "Test", a = "All tests", f = "File", l = "Last", n = "Nearest", s = "Suite" },
    u = "Undotree",
    U = "Uppercase word",
    ["1"] = "Focus on buffer with index 1",
    [";"] = "Add semicolon to end of line",
    [","] = "Add comma to end of line",
    ["("] = "Wrap word/selection in brackets",
    ["{"] = "Wrap word/selection in parenthesis",
    ['"'] = "Wrap word/selection in quotes",
    ["["] = "Replace cursor word in FILE",
    ["]"] = "Replace cursor word in LINE",
  },
  m = {
    name = "Marks",
    b = {
      name = "Bookmarks",
      a = "Annotate a bookmark",
      d = "Delete bookmark under cursor",
      s = {
        name = "Set Bookmarks",
        ["0"] = "Bookmark 0",
        ["1"] = "Bookmark 1",
        ["2"] = "Bookmark 2",
        ["3"] = "Bookmark 3",
        ["4"] = "Bookmark 4",
        ["5"] = "Bookmark 5",
        ["6"] = "Bookmark 6",
        ["7"] = "Bookmark 7",
        ["8"] = "Bookmark 8",
        ["9"] = "Bookmark 9",
      },
      x = {
        name = "Delete Bookmarks",
        ["0"] = "Bookmark 0",
        ["1"] = "Bookmark 1",
        ["2"] = "Bookmark 2",
        ["3"] = "Bookmark 3",
        ["4"] = "Bookmark 4",
        ["5"] = "Bookmark 5",
        ["6"] = "Bookmark 6",
        ["7"] = "Bookmark 7",
        ["8"] = "Bookmark 8",
        ["9"] = "Bookmark 9",
      },
      ["["] = "Go to previous bookmark",
      ["]"] = "Go to next bookmark",
    },
    d = "Delete mark on the current line",
    m = "Toggle mark",
    p = "Preview mark",
    s = "Set mark",
    x = {
      name = "Delete Marks",
      b = "Delete all marks in the buffer",
      x = "Delete a given mark",
    },
    ["["] = "Go to previous mark",
    ["]"] = "Go to next mark",
    [","] = "Set the next available mark",
  },
}, {})
