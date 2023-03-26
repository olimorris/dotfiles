local Job = require("plenary.job")

function om.ChangeFiletype()
  vim.ui.input({ prompt = "Change filetype to: " }, function(new_ft)
    if new_ft ~= nil then vim.bo.filetype = new_ft end
  end)
end

local conceal_ns = vim.api.nvim_create_namespace("class_conceal")

---Conceal HTML class attributes. Ideal for big TailwindCSS class lists
---Ref: https://gist.github.com/mactep/430449fd4f6365474bfa15df5c02d27b
function om.ConcealHTML(bufnr)
  local language_tree = vim.treesitter.get_parser(bufnr, "html")
  local syntax_tree = language_tree:parse()
  local root = syntax_tree[1]:root()

  local query = vim.treesitter.parse_query(
    "html",
    [[
    ((attribute
        (attribute_name) @att_name (#eq? @att_name "class")
        (quoted_attribute_value (attribute_value) @class_value) (#set! @class_value conceal "…")))
    ]]
  )

  for _, captures, metadata in query:iter_matches(root, bufnr, root:start(), root:end_()) do
    local start_row, start_col, end_row, end_col = captures[2]:range()
    vim.api.nvim_buf_set_extmark(bufnr, conceal_ns, start_row, start_col, {
      end_line = end_row,
      end_col = end_col,
      conceal = metadata[2].conceal,
    })
  end
end

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

function om.GitRemoteSync()
  if not _G.GitStatus then _G.GitStatus = { ahead = 0, behind = 0, status = nil } end

  -- Fetch the remote repository
  local git_fetch = Job:new({
    command = "git",
    args = { "fetch" },
    on_start = function() _G.GitStatus.status = "pending" end,
    on_exit = function() _G.GitStatus.status = "done" end,
  })

  -- Compare local repository to upstream
  local git_upstream = Job:new({
    command = "git",
    args = { "rev-list", "--left-right", "--count", "HEAD...@{upstream}" },
    on_start = function()
      _G.GitStatus.status = "pending"
      vim.schedule(function() vim.api.nvim_exec_autocmds("User", { pattern = "GitStatusChanged" }) end)
    end,
    on_exit = function(job, _)
      local res = job:result()[1]
      if type(res) ~= "string" then
        _G.GitStatus = { ahead = 0, behind = 0, status = "error" }
        return
      end
      local _, ahead, behind = pcall(string.match, res, "(%d+)%s*(%d+)")

      _G.GitStatus = { ahead = tonumber(ahead), behind = tonumber(behind), status = "done" }
      vim.schedule(function() vim.api.nvim_exec_autocmds("User", { pattern = "GitStatusChanged" }) end)
    end,
  })

  git_fetch:start()
  git_upstream:start()
end

local function GitPushPull(action, tense)
  local branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]

  vim.ui.select({ "Yes", "No" }, {
    prompt = action:gsub("^%l", string.upper) .. " commits to/from " .. "'origin/" .. branch .. "'?",
  }, function(choice)
    if choice == "Yes" then
      Job:new({
        command = "git",
        args = { action },
        on_exit = function() om.GitRemoteSync() end,
      }):start()
    end
  end)
end

function om.GitPull() GitPushPull("pull", "from") end

function om.GitPush() GitPushPull("push", "to") end

function om.MoveToBuffer()
  vim.ui.input({ prompt = "Move to buffer number: " }, function(bufnr)
    if bufnr ~= nil then pcall(vim.cmd, "b " .. bufnr) end
  end)
end

function om.Lazygit()
  local Terminal = require("toggleterm.terminal").Terminal
  return Terminal:new({
    cmd = "lazygit",
    dir = "git_dir",
    direction = "float",
    float_opts = {
      border = "single",
      height = vim.o.lines,
      width = vim.o.columns
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
      -- vim.o.showtabline = 2
    end,
  })
end

function om.EditSnippet()
  local path = Homedir .. "/.config/snippets"
  local snippets = { "lua", "ruby", "python", "global", "package" }

  vim.ui.select(snippets, { prompt = "Snippet to edit" }, function(choice)
    if choice == nil then return end
    vim.cmd(":edit " .. path .. "/" .. choice .. ".json")
  end)
end

function om.ToggleLineNumbers()
  if vim.wo.relativenumber then
    vim.wo.relativenumber = false
  else
    vim.wo.relativenumber = true
  end
end

function om.ToggleTheme(mode)
  if vim.o.background == mode then return end

  if vim.o.background == "dark" then
    vim.cmd([[colorscheme onelight]])
  else
    vim.cmd([[colorscheme onedark]])
  end
end
