-----------------------------------LAZYGIT---------------------------------- {{{
function om.Lazygit()
  local Terminal = require("toggleterm.terminal").Terminal
  return Terminal:new({
    cmd = "lazygit",
    dir = "git_dir",
    direction = "float",
    float_opts = {
      border = "single",
      height = vim.fn.winheight("%"),
      width = vim.fn.winwidth("%"),
    },
    on_open = function(term)
      vim.o.laststatus = 0
      vim.o.showtabline = 0

      -- Escape key does nothing in Lazygit
      if vim.fn.mapcheck("jk", "t") ~= "" then
        vim.api.nvim_buf_del_keymap(term.bufnr, "t", "jk")
        vim.api.nvim_buf_del_keymap(term.bufnr, "t", "<esc>")
      end
      vim.cmd("startinsert!")
    end,
    on_close = function(term)
      vim.o.laststatus = 3
      vim.o.showtabline = 2
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
-----------------------------------PACKER----------------------------------- {{{
-- Maintain a custom command for Packer Syncing. This is useful for when we
-- have a fresh Neovim install and can't call on Legendary.nvim to run
-- custom commands.
vim.api.nvim_create_user_command("PackerInstall", function()
  require(config_namespace .. ".plugins")
  require("packer").sync()
end, {})

vim.api.nvim_create_user_command("PackerSync", function()
  local snapshot = os.date("!%Y-%m-%d %H_%M_%S")
  require(config_namespace .. ".plugins")
  require("packer").snapshot(snapshot .. "_sync")
  require("packer").sync()
  require("packer").compile()
end, {})

-- Return a list of Packer snapshots
function om.GetSnapshots()
  om.path_to_snapshots = vim.fn.stdpath("cache") .. "/packer.nvim/"
  local snapshots = vim.fn.glob(om.path_to_snapshots .. "*", true, true)

  for i, _ in ipairs(snapshots) do
    snapshots[i] = snapshots[i]:gsub(om.path_to_snapshots, "")
  end

  return snapshots
end

vim.api.nvim_create_user_command("PackerRollback", function()
  om.select("Rollback to snapshot", om.GetSnapshots(), function(choice)
    if choice == nil then
      return
    end
    require("packer").rollback(om.path_to_snapshots .. choice, require(config_namespace .. ".plugins"))
  end)
end, {})
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
