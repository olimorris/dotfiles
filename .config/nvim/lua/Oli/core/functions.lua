local opts = { noremap = true, silent = true }
--------------------------------LOAD SESSIONS------------------------------- {{{
function LoadSession()
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
om.command({
  "Sessions",
  function()
    return LoadSession()
  end,
})
--------------------------------------------------------------------------- }}}
----------------------------RELOAD NEOVIM CONFIG---------------------------- {{{
function ReloadConfig()
  local ok, plenary = om.safe_require("plenary.reload")
  if ok then
    RELOAD = plenary.reload_module
  end

  for name, _ in pairs(package.loaded) do
    if name:match("^" .. config_namespace) then
      package.loaded[name] = nil
      if ok then
        RELOAD(name)
      end
    end
  end
  dofile(vim.env.MYVIMRC)
  vim.notify("Reloaded config!")
end
om.command({
  "Reload",
  function()
    return ReloadConfig()
  end,
})
--------------------------------------------------------------------------- }}}
-----------------------------RUBOCOP FORMATTING----------------------------- {{{
function FormatWithRuboCop()
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
om.command({
  "RC",
  function()
    return FormatWithRuboCop()
  end,
})
--------------------------------------------------------------------------- }}}
----------------------------------SNIPPETS---------------------------------- {{{
function EditSnippet()
  local path = Homedir .. "/.config/snippets"
  local snippets = { "ruby", "python", "global", "package" }

  om.select("Snippet to edit", snippets, function(choice)
    if choice == nil then
      return
    end
    vim.cmd(":edit " .. path .. "/" .. choice .. ".json")
  end)
end
om.command({
  "Es",
  function()
    return EditSnippet()
  end,
})
--------------------------------------------------------------------------- }}}
---------------------------------TEST ASYNC--------------------------------- {{{
function RunTestSuiteAsync()
  om.async_run({
    command = vim.g["test#" .. vim.bo.filetype .. "#asyncrun"],
    callbacks = {
      before = function()
        vim.cmd("silent! w")
      end,
    },
  })
end
om.command({
  "TestAll",
  function()
    return RunTestSuiteAsync()
  end,
})
--------------------------------------------------------------------------- }}}
-----------------------------TOGGLE LINE NUMBERS---------------------------- {{{
function ToggleLineNumbers()
  if vim.wo.relativenumber then
    vim.wo.relativenumber = false
    vim.wo.number = true
  else
    vim.wo.relativenumber = true
    vim.wo.number = false
  end
end
vim.api.nvim_set_keymap("n", "<LocalLeader>n", "<cmd>call v:lua.ToggleLineNumbers()<CR>", opts)
--------------------------------------------------------------------------- }}}
--------------------------------TOGGLE THEME-------------------------------- {{{
function ToggleTheme(mode)
  if vim.o.background == mode then
    return
  end

  if vim.o.background == "dark" then
    vim.o.background = "light"
  else
    vim.o.background = "dark"
  end
end

om.command({
  "Tme",
  function()
    return ToggleTheme()
  end,
})
om.command({
  "Theme",
  function()
    return ToggleTheme()
  end,
})
--------------------------------------------------------------------------- }}}
