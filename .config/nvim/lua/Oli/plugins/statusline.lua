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
  "^frecency$",
  "^packer$",
  "^TelescopePrompt$",
  "^undotree$",
}

---Return the current vim mode
---@return table
local function vim_mode()
  return {
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
        s = "yello",
        S = "yello",
        ["\19"] = "yello",
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
end

---Return the current git branch in the cwd
---@return table
local function git_branch()
  return {
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
end

---Return the filename of the current buffer
---@return table
local function current_buffer()
  return {
    init = function(self)
      self.filename = vim.api.nvim_buf_get_name(0)
      self.bg_color = utils.get_highlight("Heirline").bg
    end,
    condition = function()
      return not conditions.buffer_matches({
        filetype = filetypes,
      })
    end,
    {
      provider = "",
      hl = function(self) return { fg = "bg", bg = self.bg_color } end,
    },
    {
      provider = function(self) return " " .. vim.fn.fnamemodify(self.filename, ":t") .. " " end,
      hl = function(self) return { fg = "gray", bg = self.bg_color } end,
      {
        condition = function() return vim.bo.modified end,
        provider = "[+] ",
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
end

---Return the diagnostics from the LSP servers
---@return table
local function diagnostics()
  return {
    condition = conditions.has_diagnostics,
    init = function(self)
      self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
      self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
      self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
      self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    end,
    on_click = {
      callback = function()
        vim.cmd("normal fd")
      end,
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
end

---Return the current line number as a % of total lines and the total lines in the file
---@return table
local function ruler()
  return {
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
end

local function search_results()
  return {
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
end

---Return the status of the current session
---@return table
local function session()
  return {
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
      },
      {
        provider = "",
        hl = function(self) return { bg = utils.get_highlight("Heirline").bg, fg = "bg" } end,
      },
    },
  }
end

local function overseer()
  return {
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
      },
    },
  }
end

--- Return information on the current buffers filetype
---@return table
local function filetype()
  return {
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
end

---The statusline component
---@return table
local function statusline()
  return {
    condition = function()
      return not conditions.buffer_matches({
        filetype = force_inactive_filetypes,
      })
    end,

    -- Left
    vim_mode(),
    git_branch(),
    current_buffer(),
    diagnostics(),

    -- Right
    Align,
    overseer(),
    filetype(),
    session(),
    search_results(),
    ruler(),
  }
end

---Set the statusline
---@return table
function M.setup()
  require("heirline").load_colors(vim.g.onedarkpro_colors)

  return heirline.setup(statusline())
end

return M
