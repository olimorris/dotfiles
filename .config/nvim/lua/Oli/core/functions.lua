-------------------------------CHANGE FILETYPE------------------------------ {{{
function om.ChangeFiletype()
  vim.ui.input({ prompt = "Change filetype to: " }, function(new_ft)
    if new_ft ~= nil then vim.bo.filetype = new_ft end
  end)
end
--------------------------------------------------------------------------- }}}
--------------------------------GIT BRANCHES-------------------------------- {{{
function om.ListBranches()
  local branches = vim.fn.systemlist([[git branch 2>/dev/null]])

  vim.ui.select(branches, {
    prompt = "Git branches",
  }, function(choice)
    if choice == nil then return end
    local git_cmd = string.format("git checkout %s", choice)
    vim.fn.systemlist(git_cmd)
  end)
end
--------------------------------------------------------------------------- }}}
------------------------------GIT REMOTE SYNC------------------------------- {{{
function om.GitRemoteSync()
  if not _G.GitStatus then _G.GitStatus = { ahead = 0, behind = 0 } end

  local Job = require("plenary.job")

  -- Fetch the remote repository first
  Job:new({
    command = "git",
    args = { "fetch" },
  }):start()

  -- Then compare local to upstream
  Job:new({
    command = "git",
    args = { "rev-list", "--left-right", "--count", "HEAD...@{upstream}" },
    on_exit = function(job, _)
      local res = job:result()[1]
      if type(res) ~= "string" then
        _G.GitStatus = { ahead = 0, behind = 0 }
        return
      end
      local ok, ahead, behind = pcall(string.match, res, "(%d+)%s*(%d+)")
      if not ok then
        ahead, behind = 0, 0
      end
      _G.GitStatus = { ahead = tonumber(ahead), behind = tonumber(behind) }
    end,
  }):start()
end
--------------------------------------------------------------------------- }}}
-------------------------------MOVE TO BUFFER------------------------------- {{{
function om.MoveToBuffer()
  vim.ui.input({ prompt = "Move to buffer number: " }, function(bufnr)
    if bufnr ~= nil then pcall(vim.cmd, "b " .. bufnr) end
  end)
end
--------------------------------------------------------------------------- }}}
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
-----------------------------------PACKER----------------------------------- {{{
-- Maintain a custom command for Packer Syncing. This is useful for when we
-- have a fresh Neovim install and can't call on Legendary.nvim to run
-- custom commands.
local snapshot_path = vim.fn.stdpath("cache") .. "/packer.nvim"

vim.api.nvim_create_user_command("PackerInstall", function()
  require(config_namespace .. ".plugins")
  require("packer").sync()
end, {})

function om.PackerSync()
  local snapshot = os.date("!%Y-%m-%d %H_%M_%S")
  require(config_namespace .. ".plugins")
  require("packer").snapshot(snapshot .. "_sync")
  require("packer").sync()
  require("packer").compile()
end

-- Return a list of Packer snapshots
function om.GetSnapshots()
  local snapshots = vim.fn.glob(snapshot_path .. "/*", true, true)

  for i, _ in ipairs(snapshots) do
    snapshots[i] = snapshots[i]:gsub(snapshot_path .. "/", "")
  end

  return snapshots
end

vim.api.nvim_create_user_command("PackerRollback", function()
  vim.ui.select(om.GetSnapshots(), { prompt = "Rollback to snapshot" }, function(choice)
    if choice == nil then return end

    require("packer").rollback(snapshot_path .. "/" .. choice)
    vim.notify("Rollback to: " .. choice)
  end)
end, {})
--------------------------------------------------------------------------- }}}
----------------------------------SNIPPETS---------------------------------- {{{
function om.EditSnippet()
  local path = Homedir .. "/.config/snippets"
  local snippets = { "lua", "ruby", "python", "global", "package" }

  vim.ui.select(snippets, { prompt = "Snippet to edit" }, function(choice)
    if choice == nil then return end
    vim.cmd(":edit " .. path .. "/" .. choice .. ".json")
  end)
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
  if vim.o.background == mode then return end

  if vim.o.background == "dark" then
    vim.o.background = "light"
  else
    vim.o.background = "dark"
  end
end

--------------------------------------------------------------------------- }}}
