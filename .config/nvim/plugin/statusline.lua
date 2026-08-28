local MiniStatusline = require("mini.statusline")

local api, fn = vim.api, vim.fn

om.statusline = { clicks = {} }

---Filetypes which blank the statusline entirely
local ignore_list = {
  "^alpha$",
  "^chatgpt$",
  "^frecency$",
  "^lazy$",
  "^lazyterm$",
  "^netrw$",
  "^TelescopePrompt$",
  "^undotree$",
}

---Filetypes which hide the git, filetype, session and ruler sections
local minimal_list = {
  "^git.*",
  "fugitive",
  "alpha",
  "^neo--tree$",
  "^neotest--summary$",
  "^neo--tree--popup$",
  "^NvimTree$",
  "snacks_dashboard",
  "^toggleterm$",
}

---Window widths below which a section shortens itself. The statusline is global
---(laststatus=3), so this is measured against the whole terminal
local trunc = {
  mode = 90,
  git = 70,
  filetype = 90,
  codecompanion = 110,
  search = 75,
}

---Make a section respond to a mouse click
---@param name string A key in `om.statusline.click`
---@param str string
---@return string
local function clickable(name, str)
  if str == "" then
    return ""
  end
  return "%@v:lua.om.statusline.clicks." .. name .. "@" .. str .. "%X"
end

---Does the current buffer's filetype match any of the given Lua patterns?
---@param patterns string[]
---@return boolean
local function matches(patterns)
  local filetype = vim.bo.filetype
  for _, pattern in ipairs(patterns) do
    if filetype:find(pattern) then
      return true
    end
  end
  return false
end

local function minimised()
  return matches(minimal_list)
end

local function in_codecompanion()
  return package.loaded.codecompanion ~= nil and vim.bo.filetype == "codecompanion"
end

-- Sections -------------------------------------------------------------------

local codecompanion = { requesting = false, tool_approval = false }

local section = {
  ---@return table Section strings, each possibly empty, plus the ahead/behind highlights
  git = function()
    local out = {
      branch = "",
      pending = "",
      behind = "",
      ahead = "",
      behind_hl = "StatuslineBlock",
      ahead_hl = "StatuslineBlock",
    }

    local dict = vim.b.gitsigns_status_dict
    if not dict or minimised() then
      return out
    end

    local worktree = dict.gitdir and dict.gitdir:match("worktrees/([^/]+)$")
    local head = (dict.head == "" or dict.head == nil) and "main" or dict.head
    out.branch = " "
    if not MiniStatusline.is_truncated(trunc.git) then
      out.branch = out.branch .. (worktree and worktree .. "/" or "") .. head
    end

    local status = _G.GitStatus
    if not status or (status.ahead == 0 and status.behind == 0) then
      return out
    end

    local behind, ahead = status.behind or 0, status.ahead or 0

    out.pending = status.status == "pending" and "" or ""
    out.behind = behind .. ""
    out.ahead = ahead .. ""
    out.behind_hl = behind > 0 and "StatuslineBlockBehind" or "StatuslineBlock"
    out.ahead_hl = ahead > 0 and "StatuslineBlockAhead" or "StatuslineBlock"

    return out
  end,

  filetype = function()
    if minimised() or in_codecompanion() then
      return ""
    end

    local filename = api.nvim_buf_get_name(0)
    local icon = require("nvim-web-devicons").get_icon(filename, fn.fnamemodify(filename, ":e"), { default = true })

    if MiniStatusline.is_truncated(trunc.filetype) then
      return icon or ""
    end

    return (icon and icon .. " " or "") .. vim.bo.filetype:lower()
  end,

  session = function()
    if minimised() or in_codecompanion() or not package.loaded.persisted then
      return ""
    end
    return vim.g.persisting and "󰅠 " or "󰅣 "
  end,

  macro = function()
    return fn.reg_recording()
  end,

  ruler = function()
    if minimised() then
      return ""
    end
    -- %P = percentage through the file, %L = total lines in the buffer
    return "%P% /%2L"
  end,

  ---@return table Section strings, each possibly empty
  codecompanion = function()
    local out = { context = "", model = "", tokens = "", cycles = "" }
    if not in_codecompanion() then
      return out
    end

    local context = _G.codecompanion_current_context
    if
      context
      and not codecompanion.requesting
      and not MiniStatusline.is_truncated(trunc.codecompanion)
      and api.nvim_buf_is_valid(context)
    then
      out.context = " " .. fn.fnamemodify(api.nvim_buf_get_name(context), ":t")
    end

    local metadata = _G.codecompanion_chat_metadata and _G.codecompanion_chat_metadata[api.nvim_get_current_buf()]
    if not metadata then
      return out
    end

    if type(metadata.adapter and metadata.adapter.model) == "string" and not codecompanion.requesting then
      out.model = " " .. metadata.adapter.model
    end
    if (metadata.tokens or 0) > 0 then
      out.tokens = "󰔖 " .. metadata.tokens
    end
    if (metadata.cycles or 0) > 0 then
      out.cycles = " " .. metadata.cycles
    end

    return out
  end,
}

-- Click handlers -------------------------------------------------------------
local click_handlers = {
  mode = function()
    local mode = fn.mode()
    if mode == "n" then
      vim.cmd("startinsert")
    elseif mode == "i" then
      vim.cmd("stopinsert")
    end
  end,
  session = function()
    vim.cmd("Persisted toggle")
  end,
}
om.statusline.clicks = click_handlers

-- Content --------------------------------------------------------------------

---A space drawn in the statusline's own background, so blocks don't touch
local GAP = "%#StatusLine# "

---Reset the highlight before the alignment marker, otherwise the empty middle of
---the bar is painted in whichever block's colours came last
local ALIGN = "%#StatusLine#%="

---@param group table
---@return boolean
local function is_visible(group)
  for _, str in ipairs(group.strings or {}) do
    if str ~= "" then
      return true
    end
  end
  return false
end

---Flatten blocks into mini.statusline groups
---@param blocks table[]
---@return table[]
local function join(blocks)
  local out = {}

  for _, block in ipairs(blocks) do
    local groups = vim.tbl_filter(is_visible, block.strings and { block } or block)
    if #groups > 0 then
      if #out > 0 then
        out[#out + 1] = GAP
      end
      vim.list_extend(out, groups)
    end
  end

  return out
end

local function content()
  if matches(ignore_list) then
    return ""
  end

  local mode, mode_group = MiniStatusline.section_mode({ trunc_width = trunc.mode })
  local git = section.git()
  local cc = section.codecompanion()

  local left = join({
    { hl = mode_group, strings = { clickable("mode", mode:upper()) } },
    {
      { hl = "StatuslineBlock", strings = { git.branch, git.pending } },
      { hl = git.behind_hl, strings = { git.behind } },
      { hl = git.ahead_hl, strings = { git.ahead } },
    },
  })

  local right = join({
    { hl = "StatuslineApproval", strings = { codecompanion.tool_approval and "󱙺" or "" } },
    { hl = "StatuslineRequest", strings = { codecompanion.requesting and "" or "" } },
    { hl = "StatuslineBlock", strings = { section.filetype() } },
    { hl = "StatuslineBlock", strings = { clickable("session", section.session()) } },
    { hl = "StatuslineMacro", strings = { section.macro() } },
    {
      { hl = "StatuslineText", strings = { cc.context } },
      { hl = "StatuslineText", strings = { cc.model } },
      { hl = "StatuslineBlock", strings = { cc.tokens } },
      { hl = "StatuslineBlock", strings = { cc.cycles } },
    },
    { hl = "StatuslineSearch", strings = { MiniStatusline.section_searchcount({ trunc_width = trunc.search }) } },
    { hl = "StatuslineRuler", strings = { section.ruler() } },
  })

  left[#left + 1] = ALIGN
  return MiniStatusline.combine_groups(vim.list_extend(left, right))
end

-- Setup ----------------------------------------------------------------------
MiniStatusline.setup({
  content = { active = content, inactive = content },
})

local group = api.nvim_create_augroup("Statusline", { clear = true })
local redraw = vim.schedule_wrap(function()
  vim.cmd("redrawstatus")
end)

api.nvim_create_autocmd("ModeChanged", { group = group, pattern = "*:*", callback = redraw })
api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, { group = group, callback = redraw })
api.nvim_create_autocmd("User", {
  group = group,
  pattern = {
    "GitSignsUpdate",
    "GitStatusChanged",
    "PersistedToggle",
    "PersistedDeletePost",
    "CodeCompanionACPConnected",
    "CodeCompanionACPModeChanged",
    "CodeCompanionChatModel",
    "CodeCompanionChatOpened",
    "CodeCompanionContextChanged",
  },
  callback = redraw,
})

api.nvim_create_autocmd("User", {
  group = group,
  pattern = "CodeCompanionRequest*",
  callback = function(args)
    if args.match == "CodeCompanionRequestStarted" then
      codecompanion.requesting = true
    elseif args.match == "CodeCompanionRequestFinished" then
      codecompanion.requesting = false
    end
    redraw()
  end,
})

api.nvim_create_autocmd("User", {
  group = group,
  pattern = "CodeCompanionToolApproval*",
  callback = function(args)
    if args.match == "CodeCompanionToolApprovalRequested" then
      codecompanion.tool_approval = true
    elseif args.match == "CodeCompanionToolApprovalFinished" then
      codecompanion.tool_approval = false
    end
    redraw()
  end,
})
