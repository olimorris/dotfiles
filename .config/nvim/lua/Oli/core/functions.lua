-----------------------------------LAZYGIT---------------------------------- {{{
function om.Lazygit()
  local Terminal = require("toggleterm.terminal").Terminal
  return Terminal:new({
    cmd = "lazygit",
    dir = "git_dir",
    direction = "float",
    float_opts = {
      border = "double",
      width = function()
        return math.floor(0.95 * vim.fn.winwidth("%"))
      end,
    },
    on_open = function(term)
      vim.cmd("startinsert!")
      vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
    end,
  })
end
--------------------------------------------------------------------------- }}}
--------------------------------LOAD SESSIONS------------------------------- {{{
function om.LoadSession()
  local ok, persisted = om.safe_require("persisted")
  if not ok then
    return
  end

  local sessions = persisted.list()
  local path_to_trim = Sessiondir .. "/"

  local sessions_short = {}
  for _, session in pairs(sessions) do
    sessions_short[#sessions_short + 1] = session:gsub(path_to_trim, "")
  end

  om.select("Session to load", sessions_short, function(choice)
    if choice == nil then
      return
    end
    vim.cmd("source " .. vim.fn.fnameescape(path_to_trim .. choice))
    vim.cmd('lua require("persisted").stop()')
  end)
end
--------------------------------------------------------------------------- }}}
-----------------------------RUBOCOP FORMATTING----------------------------- {{{
function om.FormatWithRuboCop()
  -- Runs unsafe options on the code base!
  local filepath = vim.fn.expand("%:p")
  om.async_run({
    command = "rubocop",
    args = "--auto-correct-all --display-time " .. filepath,
    callbacks = {
      before = function()
        vim.cmd("silent! w")
      end,
      after = function()
        vim.cmd("silent! e %")
      end,
    },
  })
end
--------------------------------------------------------------------------- }}}
----------------------------------SNIPPETS---------------------------------- {{{
function om.EditSnippet()
  local path = Homedir .. "/.config/snippets"
  local snippets = { "ruby", "python", "global", "package" }

  om.select("Snippet to edit", snippets, function(choice)
    if choice == nil then
      return
    end
    vim.cmd(":edit " .. path .. "/" .. choice .. ".json")
  end)
end
--------------------------------------------------------------------------- }}}
---------------------------------TEST ASYNC--------------------------------- {{{
function om.RunTestSuiteAsync()
  om.async_run({
    command = vim.g["test#" .. vim.bo.filetype .. "#asyncrun"],
    callbacks = {
      before = function()
        vim.cmd("silent! w")
      end,
    },
  })
end
--------------------------------------------------------------------------- }}}
-----------------------------TOGGLE LINE NUMBERS---------------------------- {{{
function om.ToggleLineNumbers()
  if vim.wo.relativenumber then
    vim.wo.relativenumber = false
  else
    vim.wo.relativenumber = true
  end
end
--------------------------------------------------------------------------- }}}
--------------------------------TOGGLE THEME-------------------------------- {{{
function om.ToggleTheme(mode)
  if vim.o.background == mode then
    return
  end

  if vim.o.background == "dark" then
    vim.o.background = "light"
  else
    vim.o.background = "dark"
  end
end
--------------------------------------------------------------------------- }}}
