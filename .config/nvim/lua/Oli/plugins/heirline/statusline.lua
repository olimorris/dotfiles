local M = {}

local utils = require("heirline.utils")
local conditions = require("heirline.conditions")

local LeftSlantStart = {
  provider = "",
  hl = { fg = "bg", bg = "statusline_bg" },
}
local LeftSlantEnd = {
  provider = "",
  hl = { fg = "statusline_bg", bg = "bg" },
}
local RightSlantStart = {
  provider = "",
  hl = { fg = "statusline_bg", bg = "bg" },
}
local RightSlantEnd = {
  provider = "",
  hl = { fg = "bg", bg = "statusline_bg" },
}

---Return the current vim mode
M.VimMode = {
  init = function(self)
    self.mode = vim.fn.mode(1)
    self.mode_color = self.mode_colors[self.mode:sub(1, 1)]

    if not self.once then
      vim.api.nvim_create_autocmd("ModeChanged", {
        pattern = "*:*o",
        command = "redrawstatus",
      })
      self.once = true
    end
  end,
  static = {
    mode_names = {
      n = "NORMAL",
      no = "NORMAL",
      nov = "NORMAL",
      noV = "NORMAL",
      ["no\22"] = "NORMAL",
      niI = "NORMAL",
      niR = "NORMAL",
      niV = "NORMAL",
      nt = "NORMAL",
      v = "VISUAL",
      vs = "VISUAL",
      V = "VISUAL",
      Vs = "VISUAL",
      ["\22"] = "VISUAL",
      ["\22s"] = "VISUAL",
      s = "SELECT",
      S = "SELECT",
      ["\19"] = "SELECT",
      i = "INSERT",
      ic = "INSERT",
      ix = "INSERT",
      R = "REPLACE",
      Rc = "REPLACE",
      Rx = "REPLACE",
      Rv = "REPLACE",
      Rvc = "REPLACE",
      Rvx = "REPLACE",
      c = "COMMAND",
      cv = "Ex",
      r = "...",
      rm = "M",
      ["r?"] = "?",
      ["!"] = "!",
      t = "TERM",
    },
    mode_colors = {
      n = "purple",
      i = "green",
      v = "orange",
      V = "orange",
      ["\22"] = "orange",
      c = "orange",
      s = "yellow",
      S = "yellow",
      ["\19"] = "yellow",
      r = "green",
      R = "green",
      ["!"] = "red",
      t = "red",
    },
  },
  {
    provider = function(self) return " %2(" .. self.mode_names[self.mode] .. "%) " end,
    hl = function(self) return { fg = "bg", bg = self.mode_color } end,
    on_click = {
      callback = function() vim.cmd("Alpha") end,
      name = "heirline_mode",
    },
    update = {
      "ModeChanged",
    },
  },
  {
    provider = "",
    hl = function(self) return { fg = self.mode_color, bg = "bg" } end,
  },
}

---Return the current git branch in the cwd
M.GitBranch = {
  condition = conditions.is_git_repo,
  init = function(self) self.status_dict = vim.b.gitsigns_status_dict end,
  {
    condition = function(self)
      return not conditions.buffer_matches({
        filetype = self.filetypes,
      })
    end,
    LeftSlantStart,
    {
      provider = function(self)
        return "  " .. (self.status_dict.head == "" and "main" or self.status_dict.head) .. " "
      end,
      on_click = {
        callback = function() om.ListBranches() end,
        name = "git_change_branch",
      },
      hl = { fg = "gray", bg = "statusline_bg" },
    },
    {
      condition = function() return (_G.GitStatus ~= nil and (_G.GitStatus.ahead ~= 0 or _G.GitStatus.behind ~= 0)) end,
      {
        condition = function() return _G.GitStatus.status == "pending" end,
        provider = " ",
        hl = { fg = "gray", bg = "statusline_bg" },
      },
      {
        provider = function() return _G.GitStatus.behind .. " " end,
        hl = function() return { fg = _G.GitStatus.behind == 0 and "gray" or "red", bg = "statusline_bg" } end,
        on_click = {
          callback = function()
            if _G.GitStatus.behind > 0 then om.GitPull() end
          end,
          name = "git_pull",
        },
      },
      {
        provider = function() return _G.GitStatus.ahead .. " " end,
        hl = function() return { fg = _G.GitStatus.ahead == 0 and "gray" or "green", bg = "statusline_bg" } end,
        on_click = {
          callback = function()
            if _G.GitStatus.ahead > 0 then om.GitPush() end
          end,
          name = "git_push",
        },
      },
    },
    LeftSlantEnd,
  },
}

---Return the filename of the current buffer
local FileBlock = {
  init = function(self) self.filename = vim.api.nvim_buf_get_name(0) end,
  condition = function(self)
    return not conditions.buffer_matches({
      filetype = self.filetypes,
    })
  end,
}

local FileName = {
  provider = function(self)
    local filename = vim.fn.fnamemodify(self.filename, ":t")
    if filename == "" then return "[No Name]" end
    return " " .. filename .. " "
  end,
  on_click = {
    callback = function() vim.cmd("Telescope find_files") end,
    name = "find_files",
  },
  hl = { fg = "gray", bg = "statusline_bg" },
}

local FileFlags = {
  -- {
  --   condition = function() return vim.bo.modified end,
  --   provider = " ",
  --   hl = { fg = "gray" },
  -- },
  {
    condition = function() return not vim.bo.modifiable or vim.bo.readonly end,
    provider = " ",
    hl = { fg = "gray" },
  },
}

M.FileNameBlock = utils.insert(FileBlock, LeftSlantStart, utils.insert(FileName, FileFlags), LeftSlantEnd)

---Return the LspDiagnostics from the LSP servers
M.LspDiagnostics = {
  condition = conditions.has_diagnostics,
  init = function(self)
    self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
  end,
  on_click = {
    callback = function() vim.cmd("normal gf") end,
    name = "heirline_diagnostics",
  },
  update = { "DiagnosticChanged", "BufEnter" },
  -- Errors
  {
    condition = function(self) return self.errors > 0 end,
    hl = { fg = "bg", bg = "red" },
    {
      {
        provider = "",
      },
      {
        provider = function(self) return vim.fn.sign_getdefined("DiagnosticSignError")[1].text .. self.errors end,
      },
      {
        provider = "",
        hl = { bg = "bg", fg = "red" },
      },
    },
  },
  -- Warnings
  {
    condition = function(self) return self.warnings > 0 end,
    hl = { fg = "bg", bg = "yellow" },
    {
      {
        provider = "",
      },
      {
        provider = function(self) return vim.fn.sign_getdefined("DiagnosticSignWarn")[1].text .. self.warnings end,
      },
      {
        provider = "",
        hl = { bg = "bg", fg = "yellow" },
      },
    },
  },
  -- Hints
  {
    condition = function(self) return self.hints > 0 end,
    hl = { fg = "gray", bg = "bg" },
    {
      {
        provider = function(self)
          local spacer = (self.errors > 0 or self.warnings > 0) and " " or ""
          return spacer .. vim.fn.sign_getdefined("DiagnosticSignHint")[1].text .. self.hints
        end,
      },
    },
  },
  -- Info
  {
    condition = function(self) return self.info > 0 end,
    hl = { fg = "gray", bg = "bg" },
    {
      {
        provider = function(self)
          local spacer = (self.errors > 0 or self.warnings > 0 or self.hints) and " " or ""
          return spacer .. vim.fn.sign_getdefined("DiagnosticSignInfo")[1].text .. self.info
        end,
      },
    },
  },
}

---Return the current line number as a % of total lines and the total lines in the file
M.Ruler = {
  condition = function(self)
    return not conditions.buffer_matches({
      filetype = self.filetypes,
    })
  end,
  {
    provider = "",
    hl = { fg = "gray", bg = "bg" },
  },
  {
    -- %L = number of lines in the buffer
    -- %P = percentage through file of displayed window
    provider = " %P% /%2L ",
    hl = { fg = "bg", bg = "gray" },
    on_click = {
      callback = function()
        local line = vim.api.nvim_win_get_cursor(0)[1]
        local total_lines = vim.api.nvim_buf_line_count(0)

        if math.floor((line / total_lines)) > 0.5 then
          vim.cmd("normal! gg")
        else
          vim.cmd("normal! G")
        end
      end,
      name = "heirline_ruler",
    },
  },
}

M.SearchResults = {
  condition = function(self)
    local lines = vim.api.nvim_buf_line_count(0)
    if lines > 50000 then return end

    local query = vim.fn.getreg("/")
    if query == "" then return end

    if query:find("@") then return end

    local search_count = vim.fn.searchcount({ recompute = 1, maxcount = -1 })
    local active = false
    if vim.v.hlsearch and vim.v.hlsearch == 1 and search_count.total > 0 then active = true end
    if not active then return end

    query = query:gsub([[^\V]], "")
    query = query:gsub([[\<]], ""):gsub([[\>]], "")

    self.query = query
    self.count = search_count
    return true
  end,
  {
    provider = "",
    hl = function() return { fg = utils.get_highlight("Substitute").bg, bg = "bg" } end,
  },
  {
    provider = function(self)
      return table.concat({
        " ",
        self.count.current,
        "/",
        self.count.total,
        " ",
      })
    end,
    hl = function() return { bg = utils.get_highlight("Substitute").bg, fg = "bg" } end,
  },
  {
    provider = "",
    hl = function() return { bg = utils.get_highlight("Substitute").bg, fg = "bg" } end,
  },
}

---Return the status of the current session
M.Session = {
  update = { "User", pattern = "PersistedStateChange" },
  {
    condition = function(self)
      return not conditions.buffer_matches({
        filetype = self.filetypes,
      })
    end,
    RightSlantStart,
    {
      provider = function(self)
        if vim.g.persisting then
          return "   "
        else
          return "   "
        end
      end,
      hl = { fg = "gray", bg = "statusline_bg" },
      on_click = {
        callback = function() vim.cmd("SessionToggle") end,
        name = "toggle_session",
      },
    },
    RightSlantEnd,
  },
}

M.Overseer = {
  condition = function()
    local ok, _ = om.safe_require("overseer")
    if ok then return true end
  end,
  init = function(self)
    self.overseer = require("overseer")
    self.tasks = self.overseer.task_list
    self.STATUS = self.overseer.constants.STATUS
  end,
  static = {
    symbols = {
      ["FAILURE"] = "  ",
      ["CANCELED"] = "  ",
      ["SUCCESS"] = "  ",
      ["RUNNING"] = " 省",
    },
    colors = {
      ["FAILURE"] = "red",
      ["CANCELED"] = "gray",
      ["SUCCESS"] = "green",
      ["RUNNING"] = "yellow",
    },
  },
  {
    condition = function(self) return #self.tasks.list_tasks() > 0 end,
    {
      provider = function(self)
        local tasks_by_status = self.overseer.util.tbl_group_by(self.tasks.list_tasks({ unique = true }), "status")

        for _, status in ipairs(self.STATUS.values) do
          local status_tasks = tasks_by_status[status]
          if self.symbols[status] and status_tasks then
            self.color = self.colors[status]
            return self.symbols[status]
          end
        end
      end,
      hl = function(self) return { fg = self.color } end,
      on_click = {
        callback = function() require("neotest").run.run_last() end,
        name = "run_last_test",
      },
    },
  },
}

M.Dap = {
  condition = function()
    local session = require("dap").session()
    return session ~= nil
  end,
  provider = function() return "  " end,
  on_click = {
    callback = function() require("dap").continue() end,
    name = "dap_continue",
  },
  hl = { fg = "red" },
}

-- Show plugin updates available from lazy.nvim
M.Lazy = {
  condition = function(self)
    return not conditions.buffer_matches({
      filetype = self.filetypes,
    }) and require("lazy.status").has_updates()
  end,
  update = { "User", pattern = "LazyUpdate" },
  provider = function() return "  " .. require("lazy.status").updates() .. " " end,
  on_click = {
    callback = function() require("lazy").update() end,
    name = "update_plugins",
  },
  hl = { fg = "gray" },
}

--- Return information on the current buffers filetype
local FileIcon = {
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ":e")
    self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
  end,
  provider = function(self) return self.icon and (" " .. self.icon .. " ") end,
  on_click = {
    callback = function() om.ChangeFiletype() end,
    name = "change_ft",
  },
  hl = { fg = "gray", bg = "statusline_bg" },
}

local FileType = {
  provider = function() return string.lower(vim.bo.filetype) .. " " end,
  on_click = {
    callback = function() om.ChangeFiletype() end,
    name = "change_ft",
  },
  hl = { fg = "gray", bg = "statusline_bg" },
}

M.FileType = utils.insert(FileBlock, RightSlantStart, FileIcon, FileType, RightSlantEnd)

--- Return information on the current file's encoding
M.FileEncoding = {
  condition = function(self)
    return not conditions.buffer_matches({
      filetype = self.filetypes,
    })
  end,
  RightSlantStart,
  {
    provider = function()
      local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc -- :h 'enc'
      return " " .. enc .. " "
    end,
    hl = {
      fg = "gray",
      bg = "statusline_bg",
    },
  },
  RightSlantEnd,
}

return M
