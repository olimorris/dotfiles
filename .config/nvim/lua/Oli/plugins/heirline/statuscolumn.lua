local M = {}

local conditions = require("heirline.conditions")
local gitsigns_avail, gitsigns = pcall(require, "gitsigns")

local function get_signs(self, group)
  local signs = vim.fn.sign_getplaced(vim.api.nvim_get_current_buf(), {
    group = "*",
    lnum = vim.v.lnum,
  })

  if #signs == 0 or signs[1].signs == nil then
    self.sign = nil
    self.has_sign = false
    return
  end

  return vim.tbl_filter(function(sign) return vim.startswith(sign.group, group) end, signs[1].signs)
end

M.static = {
  click_args = function(self, minwid, clicks, button, mods)
    local args = {
      minwid = minwid,
      clicks = clicks,
      button = button,
      mods = mods,
      mousepos = vim.fn.getmousepos(),
    }
    local sign = vim.fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol)
    if sign == " " then sign = vim.fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol - 1) end
    args.sign = self.signs[sign]
    vim.api.nvim_set_current_win(args.mousepos.winid)
    vim.api.nvim_win_set_cursor(0, { args.mousepos.line, 0 })

    return args
  end,
  handlers = {
    line_number = function(args)
      local dap_avail, dap = pcall(require, "dap")
      if dap_avail then vim.schedule(dap.toggle_breakpoint) end
    end,
    diagnostics = function(args) vim.schedule(vim.diagnostic.open_float) end,
    git_signs = function(args)
      if gitsigns_avail then vim.schedule(gitsigns.preview_hunk) end
    end,
    fold = function(args)
      local lnum = args.mousepos.line
      if vim.fn.foldlevel(lnum) <= vim.fn.foldlevel(lnum - 1) then return end
      vim.cmd.execute("'" .. lnum .. "fold" .. (vim.fn.foldclosed(lnum) == -1 and "close" or "open") .. "'")
    end,
  },
}

M.init = function(self)
  self.signs = {}
  for _, sign in ipairs(vim.fn.sign_getdefined()) do
    if sign.text then self.signs[sign.text:gsub("%s", "")] = sign end
  end
end

M.line_numbers = {
  provider = function()
    if vim.v.virtnum > 0 then return "" end

    if vim.v.relnum == 0 then return vim.v.lnum end

    return vim.v.relnum
  end,
  on_click = {
    name = "line_number_click",
    callback = function(self, ...)
      if self.handlers.line_number then self.handlers.line_number(self.click_args(self, ...)) end
    end,
  },
}

M.diagnostics = {
  condition = function() return conditions.has_diagnostics() end,
  static = {
    sign_text = {
      DiagnosticSignError = " ",
      DiagnosticSignWarn = " ",
      DiagnosticSignInfo = " ",
      DiagnosticSignHint = " ",
    },
  },
  init = function(self)
    local signs = get_signs(self, "vim.diagnostic")

    if #signs == 0 or signs == nil then
      self.sign = nil
    else
      self.sign = signs[1]
    end

    self.has_sign = self.sign ~= nil
  end,
  provider = function(self)
    if self.has_sign then return self.sign_text[self.sign.name] end
    return ""
  end,
  hl = function(self)
    if self.has_sign then return self.sign.name end
  end,
  on_click = {
    name = "diagnostics_click",
    callback = function(self, ...)
      if self.handlers.diagnostics then self.handlers.diagnostics(self.click_args(self, ...)) end
    end,
  },
}

M.debug = {
  init = function(self)
    local signs = get_signs(self, "dap")

    if #signs == 0 or signs == nil then
      self.sign = nil
    else
      self.sign = signs[1]
    end

    self.has_sign = self.sign ~= nil
  end,
  provider = function(self)
    if self.has_sign then return "" end
    return ""
  end,
  hl = function(self)
    if self.has_sign then return "DebugBreakpoint" end
  end,
}

M.folds = {
  provider = function()
    if vim.v.virtnum ~= 0 then return "" end

    local lnum = vim.v.lnum
    local icon = " "

    if vim.fn.foldlevel(lnum) > vim.fn.foldlevel(lnum - 1) then
      if vim.fn.foldclosed(lnum) == -1 then
        icon = ""
      else
        icon = ""
      end
    end

    return icon
  end,
  on_click = {
    name = "fold_click",
    callback = function(self, ...)
      if self.handlers.fold then self.handlers.fold(self.click_args(self, ...)) end
    end,
  },
}

M.git_signs = {
  init = function(self)
    local signs = vim.fn.sign_getplaced(vim.api.nvim_get_current_buf(), {
      group = "gitsigns_vimfn_signs_",
      id = vim.v.lnum,
      lnum = vim.v.lnum,
    })

    if #signs == 0 or signs[1].signs == nil or #signs[1].signs == 0 or signs[1].signs[1].name == nil then
      self.sign = nil
    else
      self.sign = signs[1].signs[1]
    end

    self.has_sign = self.sign ~= nil
  end,
  provider = " ▏",
  hl = function(self)
    if self.has_sign then return self.sign.name end
    return "HeirlineStatusColumn"
  end,
  on_click = {
    name = "gitsigns_click",
    callback = function(self, ...)
      if self.handlers.git_signs then self.handlers.git_signs(self.click_args(self, ...)) end
    end,
  },
}

return M
