local utils = require("heirline.utils")
local conditions = require("heirline.conditions")
local v, fn, api = vim.v, vim.fn, vim.api

---Winbar configuration for heirline.nvim
---@return table
local function winbar()
  local bit = require("bit")

  local sep = "  "

  local Spacer = {
    provider = " ",
  }

  local VimLogo = {
    provider = " ",
    hl = "VimLogo",
  }

  local Filepath = {
    static = {
      modifiers = {
        dirname = ":s?/Users/Oli/.dotfiles?dotfiles?:s?.config/nvim/lua/Oli?Neovim?:s?/Users/Oli/Code?Code?",
      },
    },
    init = function(self)
      self.current_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")

      self.filepath = vim.fn.fnamemodify(self.current_dir, self.modifiers.dirname or nil)
      self.short_path = vim.fn.fnamemodify(vim.fn.expand("%:h"), self.modifiers.dirname or nil)
      if self.filepath == "" then
        self.filepath = "[No Name]"
      end
    end,
    hl = "HeirlineWinbar",
    {
      condition = function(self)
        return self.filepath ~= "."
      end,
      flexible = 2,
      {
        provider = function(self)
          return table.concat(vim.fn.split(self.filepath, "/"), sep) .. sep
        end,
      },
      {
        provider = function(self)
          local filepath = vim.fn.pathshorten(self.short_path)
          return table.concat(vim.fn.split(self.short_path, "/"), sep) .. sep
        end,
      },
      {
        provider = "",
      },
    },
  }

  local FileIcon = {
    condition = function()
      return package.loaded["nvim-web-devicons"]
    end,
    init = function(self)
      self.icon, self.icon_color =
        require("nvim-web-devicons").get_icon_color_by_filetype(vim.bo.filetype, { default = true })
    end,
    provider = function(self)
      return self.icon and (self.icon .. " ")
    end,
    hl = function(self)
      return { fg = self.icon_color }
    end,
  }

  local FileType = {
    condition = function()
      return vim.bo.filetype ~= ""
    end,
    FileIcon,
  }

  local FileName = {
    static = {
      modifiers = {
        dirname = ":s?/Users/Oli/.dotfiles?dotfiles?:s?.config/nvim/lua?Neovim?:s?/Users/Oli/Code?Code?",
      },
    },
    init = function(self)
      local filename
      local has_oil, oil = pcall(require, "oil")
      if has_oil then
        filename = oil.get_current_dir()
      end
      if not filename then
        filename =
          vim.fn.fnamemodify(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":."), self.modifiers.dirname or nil)
      end
      if filename == "" then
        self.path = ""
        self.name = "[No Name]"
        return
      end
      -- now, if the filename would occupy more than 90% of the available
      -- space, we trim the file path to its initials
      if not conditions.width_percent_below(#filename, 0.90) then
        filename = vim.fn.pathshorten(filename)
      end

      self.path = filename:match("^(.*)/")
      self.name = filename:match("([^/]+)$")
    end,
    {
      provider = function(self)
        if self.path then
          return self.path .. "/"
        end
      end,
      hl = "HeirlineWinbar",
    },
    {
      provider = function(self)
        return self.name
      end,
      hl = "HeirlineWinbarEmphasis",
    },
    on_click = {
      callback = function(self)
        require("aerial").toggle()
      end,
      name = "wb_filename_click",
    },
  }
  local FileFlags = {
    {
      condition = function()
        return vim.bo.modified
      end,
      provider = " ",
      hl = { fg = "red" },
    },
    {
      condition = function()
        return not vim.bo.modifiable or vim.bo.readonly
      end,
      provider = " ",
      hl = { fg = "blue" },
    },
  }

  -- Inspired by:
  -- https://github.com/eli-front/nvim-config/blob/5a225e1e6de3d6f1bdca2025602c3e7a4917e31b/lua/elifront/utils/status/init.lua#L32
  local Symbols = {
    condition = function()
      return package.loaded.aerial
    end,
    init = function(self)
      self.symbols = require("aerial").get_location(true) or {}
    end,
    update = "CursorMoved",
    {
      condition = function(self)
        if vim.tbl_isempty(self.symbols) then
          return false
        end
        return true
      end,
      {
        flexible = 3,
        {
          provider = function(self)
            local symbols = {}

            table.insert(symbols, { provider = sep })

            for i, d in ipairs(self.symbols) do
              local symbol = {
                -- Name
                { provider = string.gsub(d.name, "%%", "%%%%"):gsub("%s*->%s*", "") },

                -- On-Click action
                on_click = {
                  minwid = self.encode_pos(d.lnum, d.col, self.winnr),
                  callback = function(_, minwid)
                    local lnum, col, winnr = self.decode_pos(minwid)
                    vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), { lnum, col })
                  end,
                  name = "wb_symbol_click",
                },
              }

              -- Icon
              local hlgroup = string.format("Aerial%sIcon", d.kind)
              table.insert(symbol, 1, {
                provider = string.format("%s", d.icon),
                hl = (vim.fn.hlexists(hlgroup) == 1) and hlgroup or nil,
              })

              if #self.symbols >= 1 and i < #self.symbols then
                table.insert(symbol, { provider = sep })
              end

              table.insert(symbols, symbol)
            end

            self[1] = self:new(symbols, 1)
          end,
        },
        {
          provider = "",
        },
      },
      hl = "Comment",
    },
  }

  return {
    static = {
      encode_pos = function(line, col, winnr)
        return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr)
      end,
      decode_pos = function(c)
        return bit.rshift(c, 16), bit.band(bit.rshift(c, 6), 1023), bit.band(c, 63)
      end,
    },
    Spacer,
    -- Filepath,
    FileType,
    FileName,
    FileFlags,
    Symbols,
    { provider = "%=" },
    VimLogo,
  }
end

---Statuscolumn configuration for heirline.nvim
---@return table
local function statuscolumn()
  local align = { provider = "%=" }
  local spacer = { provider = " ", hl = "HeirlineStatusColumn" }

  local git_ns = api.nvim_create_namespace("gitsigns_signs_")
  local function get_signs(bufnr, lnum)
    local signs = {}

    local extmarks = api.nvim_buf_get_extmarks(
      0,
      -1,
      { lnum - 1, 0 },
      { lnum - 1, -1 },
      { details = true, type = "sign" }
    )

    for _, extmark in pairs(extmarks) do
      -- Exclude gitsigns
      if extmark[4].ns_id ~= git_ns then
        signs[#signs + 1] = {
          name = extmark[4].sign_hl_group or "",
          text = extmark[4].sign_text,
          sign_hl_group = extmark[4].sign_hl_group,
          priority = extmark[4].priority,
        }
      end
    end

    table.sort(signs, function(a, b)
      return (a.priority or 0) > (b.priority or 0)
    end)

    return signs
  end

  return {
    {
      condition = function()
        return not conditions.buffer_matches({
          buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
          filetype = { "alpha", "harpoon", "oil", "lspinfo", "snacks_dashboard", "toggleterm" },
        })
      end,
      static = {
        bufnr = api.nvim_win_get_buf(0),
        click_args = function(self, minwid, clicks, button, mods)
          local args = {
            minwid = minwid,
            clicks = clicks,
            button = button,
            mods = mods,
            mousepos = fn.getmousepos(),
          }
          local sign = fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol)
          if sign == " " then
            sign = fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol - 1)
          end
          args.sign = self.signs[sign]
          api.nvim_set_current_win(args.mousepos.winid)
          api.nvim_win_set_cursor(0, { args.mousepos.line, 0 })

          return args
        end,
        resolve = function(self, name)
          for pattern, callback in pairs(self.handlers.Signs) do
            if name:match(pattern) then
              return vim.defer_fn(callback, 100)
            end
          end
        end,
        handlers = {
          Signs = {
            ["Neotest.*"] = function(self, args)
              require("neotest").run.run()
            end,
            ["Diagnostic.*"] = function(self, args)
              vim.diagnostic.open_float()
            end,
            ["LspLightBulb"] = function(self, args)
              vim.lsp.buf.code_action()
            end,
          },
          Fold = function(args)
            local line = args.mousepos.line
            if fn.foldlevel(line) <= fn.foldlevel(line - 1) then
              return
            end
            vim.cmd.execute("'" .. line .. "fold" .. (fn.foldclosed(line) == -1 and "close" or "open") .. "'")
          end,
          GitSigns = function(self, args)
            vim.defer_fn(function()
              require("snacks").git.blame_line()
            end, 100)
          end,
        },
      },
      init = function(self)
        self.signs = {}
      end,
      -- Signs (except for GitSigns)
      {
        init = function(self)
          local signs = get_signs(self.bufnr, v.lnum)
          self.sign = signs[1]
        end,
        provider = function(self)
          return self.sign and self.sign.text or "  "
        end,
        hl = function(self)
          return self.sign and self.sign.sign_hl_group
        end,
        on_click = {
          name = "sc_sign_click",
          update = true,
          callback = function(self, ...)
            local line = self.click_args(self, ...).mousepos.line
            local sign = get_signs(self.bufnr, line)[1]
            if sign then
              self:resolve(sign.name)
            end
          end,
        },
      },
      align,
      -- Line Numbers
      {
        provider = "%=%4{v:virtnum ? '' : &nu ? (&rnu && v:relnum ? v:relnum : v:lnum) . ' ' : ''}",
        -- on_click = {
        --   name = "sc_linenumber_click",
        --   callback = function(self, ...)
        --     self.handlers.Dap(self.click_args(self, ...))
        --   end,
        -- },
      },
      -- Folds
      {
        init = function(self)
          self.can_fold = fn.foldlevel(v.lnum) > fn.foldlevel(v.lnum - 1)
        end,
        {
          condition = function(self)
            return v.virtnum == 0 and self.can_fold
          end,
          provider = "%C",
        },
        {
          condition = function(self)
            return not self.can_fold
          end,
          spacer,
        },
        on_click = {
          name = "sc_fold_click",
          callback = function(self, ...)
            self.handlers.Fold(self.click_args(self, ...))
          end,
        },
      },
      -- Git Signs
      {
        {
          condition = function()
            return conditions.is_git_repo()
          end,
          init = function(self)
            local extmark = api.nvim_buf_get_extmarks(
              0,
              git_ns,
              { v.lnum - 1, 0 },
              { v.lnum - 1, -1 },
              { limit = 1, details = true }
            )[1]

            self.sign = extmark and extmark[4]["sign_hl_group"]
          end,
          {
            provider = "│",
            hl = function(self)
              return self.sign or { fg = "bg" }
            end,
            on_click = {
              name = "sc_gitsigns_click",
              callback = function(self, ...)
                self.handlers.GitSigns(self.click_args(self, ...))
              end,
            },
          },
        },
        {
          condition = function()
            return not conditions.is_git_repo()
          end,
          spacer,
        },
      },
    },
  }
end

---Statusline configuration for heirline.nvim
---@return table
local function statusline()
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

  local IsCodeCompanion = function()
    return package.loaded.codecompanion and vim.bo.filetype == "codecompanion"
  end

  local VimMode = {
    init = function(self)
      self.mode = vim.fn.mode(1)
      self.mode_color = self.mode_colors[self.mode:sub(1, 1)]
    end,
    update = {
      "ModeChanged",
      pattern = "*:*",
      callback = vim.schedule_wrap(function()
        vim.cmd("redrawstatus")
      end),
    },
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
      provider = function(self)
        return " %2(" .. self.mode_names[self.mode] .. "%) "
      end,
      hl = function(self)
        return { fg = "bg", bg = self.mode_color }
      end,
    },
    {
      provider = "",
      hl = function(self)
        return { fg = self.mode_color, bg = "bg" }
      end,
    },
  }

  local GitBranch = {
    condition = conditions.is_git_repo,
    init = function(self)
      self.status_dict = vim.b.gitsigns_status_dict
    end,
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
          callback = function()
            om.ListBranches()
          end,
          name = "sl_git_click",
        },
        hl = { fg = "gray", bg = "statusline_bg" },
      },
      {
        condition = function()
          return (_G.GitStatus ~= nil and (_G.GitStatus.ahead ~= 0 or _G.GitStatus.behind ~= 0))
        end,
        update = {
          "User",
          pattern = "GitStatusChanged",
          callback = vim.schedule_wrap(function()
            vim.cmd("redrawstatus")
          end),
        },
        {
          condition = function()
            return _G.GitStatus.status == "pending"
          end,
          provider = " ",
          hl = { fg = "gray", bg = "statusline_bg" },
        },
        {
          provider = function()
            return _G.GitStatus.behind .. " "
          end,
          hl = function()
            return { fg = _G.GitStatus.behind == 0 and "gray" or "red", bg = "statusline_bg" }
          end,
          on_click = {
            callback = function()
              if _G.GitStatus.behind > 0 then
                om.GitPull()
              end
            end,
            name = "sl_gitpull_click",
          },
        },
        {
          provider = function()
            return _G.GitStatus.ahead .. " "
          end,
          hl = function()
            return { fg = _G.GitStatus.ahead == 0 and "gray" or "green", bg = "statusline_bg" }
          end,
          on_click = {
            callback = function()
              if _G.GitStatus.ahead > 0 then
                om.GitPush()
              end
            end,
            name = "sl_gitpush_click",
          },
        },
      },
      LeftSlantEnd,
    },
  }

  local FileBlock = {
    init = function(self)
      self.filename = vim.api.nvim_buf_get_name(0)
    end,
    condition = function(self)
      return not conditions.buffer_matches({
        filetype = self.filetypes,
      }) and not IsCodeCompanion()
    end,
  }

  local FileName = {
    provider = function(self)
      local filename = vim.fn.fnamemodify(self.filename, ":t")
      if filename == "" then
        return "[No Name]"
      end
      return " " .. filename .. " "
    end,
    on_click = {
      callback = function()
        vim.cmd("Telescope find_files")
      end,
      name = "sl_filename_click",
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
      condition = function()
        return not vim.bo.modifiable or vim.bo.readonly
      end,
      provider = " ",
      hl = { fg = "gray" },
    },
  }

  local FileNameBlock = utils.insert(FileBlock, LeftSlantStart, utils.insert(FileName, FileFlags), LeftSlantEnd)

  ---Return the LspDiagnostics from the LSP servers

  local CodeCompanionChatBuffer = {
    condition = function(self)
      return IsCodeCompanion()
    end,
    static = {
      chat_metadata = {},
    },
    init = function(self)
      local bufnr = vim.api.nvim_get_current_buf()
      if _G.codecompanion_chat_metadata then
        self.chat_metadata = _G.codecompanion_chat_metadata[bufnr]
      end
    end,
    update = {
      "User",
      pattern = {
        "CodeCompanionChatModel",
        "CodeCompanionChatOpened",
        "CodeCompanionRequest*",
        "CodeCompanionContextChanged",
      },
      callback = vim.schedule_wrap(function()
        vim.cmd("redrawstatus")
      end),
    },
    -- Current Context
    {
      condition = function(self)
        return _G.codecompanion_current_context ~= nil
          and not _G.codecompanion_processing
          and vim.api.nvim_buf_is_valid(_G.codecompanion_current_context)
      end,
      provider = function()
        local bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(_G.codecompanion_current_context), ":t")
        return "[  " .. bufname .. " ] "
      end,
      hl = { fg = "gray", bg = "bg" },
    },
    -- Model block
    {
      condition = function(self)
        return self.chat_metadata
          and self.chat_metadata.adapter
          and self.chat_metadata.adapter.model
          and not _G.codecompanion_processing
      end,
      {
        provider = function(self)
          return "  " .. self.chat_metadata.adapter.model .. " "
        end,
        hl = { fg = "gray", bg = "bg" },
      },
    },

    -- Tokens block
    {
      condition = function(self)
        return self.chat_metadata and self.chat_metadata.tokens and self.chat_metadata.tokens > 0
      end,
      RightSlantStart,
      {
        provider = function(self)
          return " 󰔖 " .. self.chat_metadata.tokens .. " "
        end,
        hl = { fg = "gray", bg = "statusline_bg" },
      },
      RightSlantEnd,
    },
    -- Cycles block
    {
      condition = function(self)
        return self.chat_metadata and self.chat_metadata.cycles and self.chat_metadata.cycles > 0
      end,
      RightSlantStart,
      {
        provider = function(self)
          return "  " .. self.chat_metadata.cycles .. " "
        end,
        hl = { fg = "gray", bg = "statusline_bg" },
      },
      RightSlantEnd,
    },
  }

  ---Return the current line number as a % of total lines and the total lines in the file
  local Ruler = {
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
        name = "sl_ruler_click",
      },
    },
  }

  local MacroRecording = {
    condition = function(self)
      return vim.fn.reg_recording() ~= ""
    end,
    update = {
      "RecordingEnter",
      "RecordingLeave",
    },
    {
      provider = "",
      hl = { fg = "blue", bg = "bg" },
    },
    {
      provider = function(self)
        return " " .. vim.fn.reg_recording() .. " "
      end,
      hl = { bg = "blue", fg = "bg" },
    },
    {
      provider = "",
      hl = { fg = "bg", bg = "blue" },
    },
  }

  local SearchResults = {
    condition = function(self)
      return vim.v.hlsearch ~= 0
    end,
    init = function(self)
      local ok, search = pcall(vim.fn.searchcount)
      if ok and search.total then
        self.search = search
      end
    end,
    {
      provider = "",
      hl = function()
        return { fg = utils.get_highlight("Substitute").bg, bg = "bg" }
      end,
    },
    {
      provider = function(self)
        local search = self.search

        return string.format(" %d/%d ", search.current, math.min(search.total, search.maxcount))
      end,
      hl = function()
        return { bg = utils.get_highlight("Substitute").bg, fg = "bg" }
      end,
    },
    {
      provider = "",
      hl = function()
        return { bg = utils.get_highlight("Substitute").bg, fg = "bg" }
      end,
    },
  }

  ---Return the status of the current session
  local Session = {
    condition = function(self)
      local bufnr = 0
      return not conditions.buffer_matches({
        filetype = self.filetypes,
      }) and package.loaded.persisted and not IsCodeCompanion()
    end,
    RightSlantStart,
    {
      provider = function(self)
        if vim.g.persisting then
          return " 󰅠  "
        end
        return " 󰅣  "
      end,
      hl = { fg = "gray", bg = "statusline_bg" },
      update = {
        "User",
        pattern = { "PersistedToggle", "PersistedDeletePost" },
        callback = vim.schedule_wrap(function()
          vim.cmd("redrawstatus")
        end),
      },
      on_click = {
        callback = function()
          vim.cmd("SessionToggle")
        end,
        name = "sl_session_click",
      },
    },
    RightSlantEnd,
  }

  local CodeCompanionRequest = {
    condition = function()
      return package.loaded.codecompanion
    end,
    static = {
      processing = false,
    },
    update = {
      "User",
      pattern = "CodeCompanionRequest*",
      callback = function(self, args)
        if args.match == "CodeCompanionRequestStarted" then
          self.processing = true
          _G.codecompanion_processing = true
        elseif args.match == "CodeCompanionRequestFinished" then
          self.processing = false
          _G.codecompanion_processing = false
        end
        vim.cmd("redrawstatus")
      end,
    },
    {
      condition = function(self)
        return self.processing
      end,
      provider = " ",
      hl = { fg = "yellow" },
    },
  }
  local CodeCompanionTools = {
    condition = function()
      return package.loaded.codecompanion
    end,
    static = {
      processing = false,
    },
    update = {
      "User",
      pattern = "CodeCompanionTools*",
      callback = function(self, args)
        if args.match == "CodeCompanionToolsStarted" then
          self.processing = true
        elseif args.match == "CodeCompanionToolsFinished" then
          self.processing = false
        end
        vim.cmd("redrawstatus")
      end,
    },
    {
      condition = function(self)
        return self.processing
      end,
      provider = " 󱙺  ",
      hl = { fg = "green" },
    },
  }

  local function OverseerTasksForStatus(status)
    return {
      condition = function(self)
        return self.tasks[status]
      end,
      provider = function(self)
        return string.format("%s%d", self.symbols[status], #self.tasks[status])
      end,
      hl = function(self)
        return {
          fg = self.colors[status],
        }
      end,
    }
  end

  --- Return information on the current buffers filetype
  local FileIcon = {
    init = function(self)
      local filename = self.filename
      local extension = vim.fn.fnamemodify(filename, ":e")
      self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
    end,
    condition = function()
      return not IsCodeCompanion()
    end,
    provider = function(self)
      return self.icon and (" " .. self.icon .. " ")
    end,
    on_click = {
      callback = function()
        om.ChangeFiletype()
      end,
      name = "sl_fileicon_click",
    },
    hl = { fg = "gray", bg = "statusline_bg" },
  }

  local FileType = {
    provider = function()
      return string.lower(vim.bo.filetype) .. " "
    end,
    on_click = {
      callback = function()
        om.ChangeFiletype()
      end,
      name = "sl_filetype_click",
    },
    hl = { fg = "gray", bg = "statusline_bg" },
  }

  FileType = utils.insert(FileBlock, RightSlantStart, FileIcon, FileType, RightSlantEnd)

  return {
    static = {
      filetypes = {
        "^git.*",
        "fugitive",
        "alpha",
        "^neo--tree$",
        "^neotest--summary$",
        "^neo--tree--popup$",
        "^NvimTree$",
        "snacks_dashboard",
        "^toggleterm$",
      },
      force_inactive_filetypes = {
        "^alpha$",
        "^chatgpt$",
        "^frecency$",
        "^lazy$",
        "^lazyterm$",
        "^netrw$",
        "^TelescopePrompt$",
        "^undotree$",
      },
    },
    condition = function(self)
      return not conditions.buffer_matches({
        filetype = self.force_inactive_filetypes,
      })
    end,
    {
      VimMode,
      GitBranch,
      { provider = "%=" },
      CodeCompanionTools,
      CodeCompanionRequest,
      FileType,
      -- FileEncoding,
      Session,
      MacroRecording,
      CodeCompanionChatBuffer,
      SearchResults,
      Ruler,
    },
  }
end

require("heirline").setup({
  winbar = winbar(),
  statusline = statusline(),
  statuscolumn = statuscolumn(),
  opts = {
    disable_winbar_cb = function(args)
      return conditions.buffer_matches({
        buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
        filetype = { "alpha", "oil", "codecompanion", "lspinfo", "snacks_dashboard", "toggleterm" },
      }, args.buf)
    end,
  },
})
