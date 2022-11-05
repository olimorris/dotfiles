local ok, heirline = om.safe_require("heirline")
if not ok then return end

local M = {}

local utils = require("heirline.utils")
local conditions = require("heirline.conditions")

local Align = { provider = "%=" }
local Space = { provider = " " }

-- Filetypes where certain elements of the statusline will not be shown
local filetypes = {
  "^aerial$",
  "^neo--tree$",
  "^neotest--summary$",
  "^neo--tree--popup$",
  "^NvimTree$",
  "^toggleterm$",
}

-- Filetypes which force the statusline to be inactive
local force_inactive_filetypes = {
  "^alpha$",
  "^DressingInput$",
  "^frecency$",
  "^packer$",
  "^TelescopePrompt$",
  "^undotree$",
}

---Return the current vim mode
local VimMode = {
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
local GitBranch = {
  condition = conditions.is_git_repo,
  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
    self.bg_color = utils.get_highlight("Heirline").bg
  end,
  {
    condition = function()
      return not conditions.buffer_matches({
        filetype = filetypes,
      })
    end,
    on_click = {
      callback = function() om.ListBranches() end,
      name = "list_git_branches",
    },
    {
      provider = "",
      hl = function(self) return { fg = "bg", bg = self.bg_color } end,
    },
    {
      provider = function(self) return "  " .. self.status_dict.head .. " " end,
      hl = function(self) return { fg = "gray", bg = self.bg_color } end,
    },
    {
      provider = "",
      hl = function(self) return { fg = self.bg_color, bg = "bg" } end,
    },
  },
}

---Return the filename of the current buffer
local CurrentBuffer = {
  condition = function()
    return not conditions.buffer_matches({
      filetype = filetypes,
    })
  end,
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(0)
    self.bg_color = utils.get_highlight("Heirline").bg
  end,
  {
    provider = "",
    hl = function(self) return { fg = "bg", bg = self.bg_color } end,
  },
  {
    provider = function(self) return " " .. vim.fn.fnamemodify(self.filename, ":t") .. " " end,
    hl = function(self) return { fg = "gray", bg = self.bg_color } end,
    on_click = {
      callback = function() vim.cmd("normal ff") end,
      name = "find_files",
    },
    {
      condition = function() return vim.bo.modified end,
      provider = " ",
      hl = { fg = "gray" },
    },
    {
      condition = function() return not vim.bo.modifiable or vim.bo.readonly end,
      provider = " ",
      hl = { fg = "gray" },
    },
  },
  {
    provider = "",
    hl = function(self) return { fg = self.bg_color, bg = "bg" } end,
  },
}

---Return the LspDiagnostics from the LSP servers
local LspDiagnostics = {
  condition = conditions.has_diagnostics,
  init = function(self)
    self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
  end,
  on_click = {
    callback = function() vim.cmd("normal fd") end,
    name = "heirline_diagnostics",
  },
  update = { "DiagnosticChanged", "BufEnter" },
  -- Errors
  {
    condition = function(self) return self.errors > 0 end,
    hl = { fg = "bg", bg = utils.get_highlight("DiagnosticError").fg },
    {
      {
        provider = "",
      },
      {
        provider = function(self) return vim.fn.sign_getdefined("DiagnosticSignError")[1].text .. self.errors end,
      },
      {
        provider = "",
        hl = { bg = "bg", fg = utils.get_highlight("DiagnosticError").fg },
      },
    },
  },
  -- Warnings
  {
    condition = function(self) return self.warnings > 0 end,
    hl = { fg = "bg", bg = utils.get_highlight("DiagnosticWarn").fg },
    {
      {
        provider = "",
      },
      {
        provider = function(self) return vim.fn.sign_getdefined("DiagnosticSignWarn")[1].text .. self.warnings end,
      },
      {
        provider = "",
        hl = { bg = "bg", fg = utils.get_highlight("DiagnosticWarn").fg },
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
local Ruler = {
  condition = function()
    return not conditions.buffer_matches({
      filetype = filetypes,
    })
  end,
  {
    provider = "",
    hl = function(self) return { fg = "gray", bg = "bg" } end,
  },
  {
    -- %L = number of lines in the buffer
    -- %P = percentage through file of displayed window
    provider = " %P% /%2L ",
    hl = function(self) return { fg = "bg", bg = "gray" } end,
  },
}

local SearchResults = {
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
local Session = {
  condition = function(self) return (vim.g.persisting ~= nil) end,
  {
    condition = function()
      return not conditions.buffer_matches({
        filetype = filetypes,
      })
    end,
    {
      provider = "",
      hl = function(self) return { fg = utils.get_highlight("Heirline").bg, bg = "bg" } end,
    },
    {
      provider = function(self)
        if vim.g.persisting then
          return "   "
        elseif vim.g.persisting == false then
          return "   "
        end
      end,
      hl = function(self) return { fg = "gray", bg = utils.get_highlight("Heirline").bg } end,
      on_click = {
        callback = function() vim.cmd("SessionToggle") end,
        name = "toggle_session",
      },
    },
    {
      provider = "",
      hl = function(self) return { bg = utils.get_highlight("Heirline").bg, fg = "bg" } end,
    },
  },
}

local Overseer = {
  condition = function()
    ok, _ = om.safe_require("overseer")
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

--- Return information on the current buffers filetype
local FileType = {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(0)
    local extension = vim.fn.fnamemodify(self.filename, ":e")
    self.icon, self.icon_color =
      require("nvim-web-devicons").get_icon_color(self.filename, extension, { default = true })
  end,
  condition = function()
    return not conditions.buffer_matches({
      filetype = filetypes,
    })
  end,
  on_click = {
    callback = function() om.ChangeFiletype() end,
    name = "change_ft",
  },
  {
    provider = "",
    hl = function(self) return { fg = utils.get_highlight("Heirline").bg, bg = "bg" } end,
  },
  {
    provider = function(self) return " " .. self.icon end,
    hl = function(self) return { fg = "gray", bg = utils.get_highlight("Heirline").bg } end,
  },
  {
    provider = function() return " " .. string.lower(vim.bo.filetype) .. " " end,
    hl = function(self)
      return {
        fg = "gray",
        bg = utils.get_highlight("Heirline").bg,
      }
    end,
  },
  {
    provider = "",
    hl = function(self) return { bg = utils.get_highlight("Heirline").bg, fg = "bg" } end,
  },
}

---The statusline component
local Statusline = {
  condition = function()
    return not conditions.buffer_matches({
      filetype = force_inactive_filetypes,
    })
  end,

  -- Left
  VimMode,
  GitBranch,
  CurrentBuffer,
  LspDiagnostics,

  -- Right
  Align,
  Overseer,
  FileType,
  Session,
  SearchResults,
  Ruler,
}

---Set the statusline
function M.setup()
  require("heirline").load_colors(vim.g.onedarkpro_colors)

  heirline.setup(Statusline, nil, require("Oli.plugins.bufferline"))

  vim.o.showtabline = 2
  vim.cmd([[au FileType * if index(['wipe', 'delete'], &bufhidden) >= 0 | set nobuflisted | endif]])
end

return M
