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
  local new_branch_prompt = "Create new branch"
  table.insert(branches, 1, new_branch_prompt)

  vim.ui.select(branches, {
    prompt = "Git branches",
  }, function(choice)
    if choice == nil then return end

    if choice == new_branch_prompt then
      local new_branch = ""
      vim.ui.input({ prompt = "New branch name:" }, function(branch)
        if branch ~= nil then vim.fn.systemlist("git checkout -b " .. branch) end
      end)
    else
      vim.fn.systemlist("git checkout " .. choice)
    end
  end)
end

--------------------------------------------------------------------------- }}}
-------------------------------GIT REMOTE SYNC------------------------------ {{{
function om.GitRemoteSync()
  if not _G.GitStatus then _G.GitStatus = { ahead = 0, behind = 0, status = nil } end

  local function update_git_status()
    local Job = require("plenary.job")

    _G.GitStatus.status = "pending"

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
          _G.GitStatus = { ahead = 0, behind = 0, status = "error" }
          return
        end
        local _, ahead, behind = pcall(string.match, res, "(%d+)%s*(%d+)")

        _G.GitStatus = { ahead = tonumber(ahead), behind = tonumber(behind), status = "done" }
      end,
    }):start()
  end

  vim.schedule_wrap(update_git_status())
end

--------------------------------------------------------------------------- }}}
--------------------------------GIT PUSH/PULL------------------------------- {{{
local function GitPushPull(action, tense)
  local branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]

  vim.ui.select({ "Yes", "No" }, {
    prompt = action:gsub("^%l", string.upper) .. " commits to/from " .. "'origin/" .. branch .. "'?",
  }, function(choice)
    if choice == "Yes" then
      local Job = require("plenary.job")

      Job:new({
        command = "git",
        args = { action },
        on_exit = function() om.GitRemoteSync() end,
      }):start()
    end
  end)
end

function om.GitPull()
  GitPushPull("pull", "from")
  vim.cmd([[do User GitStatusChanged]])
end

function om.GitPush()
  GitPushPull("push", "to")
  vim.cmd([[do User GitStatusChanged]])
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
    vim.cmd([[colorscheme onelight]])
  else
    vim.cmd([[colorscheme onedark]])
  end
end

--------------------------------------------------------------------------- }}}
