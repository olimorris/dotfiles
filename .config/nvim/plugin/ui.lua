require("render-markdown").setup({
  completions = { blink = { enabled = true } },
  file_types = { "codecompanion", "codecompanion_input", "markdown", "nvim-pack" },
  latex = {
    enabled = false,
    render_modes = false,
  },
  overrides = {
    filetype = {
      codecompanion = {
        html = {
          tag = {
            buf = { icon = "󰍛 ", highlight = "CodeCompanionChatIcon" },
            file = { icon = " ", highlight = "CodeCompanionChatIcon" },
            group = { icon = " ", highlight = "CodeCompanionChatIcon" },
            help = { icon = "󰘥 ", highlight = "CodeCompanionChatIcon" },
            image = { icon = " ", highlight = "CodeCompanionChatIcon" },
            notebook = { icon = "󰠮 ", highlight = "CodeCompanionChatIcon" },
            rules = { icon = "󰧑 ", highlight = "CodeCompanionChatIcon" },
            symbols = { icon = " ", highlight = "CodeCompanionChatIcon" },
            tool = { icon = "󰯠 ", highlight = "CodeCompanionChatIcon" },
            url = { icon = "󰌹 ", highlight = "CodeCompanionChatIcon" },
          },
        },
      },
    },
  },
  render_modes = true,
  sign = { enabled = false },
})

require("gitsigns").setup({
  signs = {
    add = { text = "│" },
    change = { text = "│" },
    delete = { text = "│" },
    topdelete = { text = "│" },
    changedelete = { text = "│" },
    untracked = { text = "│" },
  },
  signs_staged_enable = false,
  numhl = false,
  linehl = false,
})

require("snacks").setup({
  styles = {
    lazygit = {
      width = 0,
      height = 0,
    },
    notification = {
      wo = { wrap = true }, -- Wrap notifications
    },
  },
  bigfile = { enabled = true },
  bufdelete = { enabled = true },
  dashboard = {
    enabled = true,
    sections = {
      function()
        return {
          align = "center",
          padding = 1,
          text = {
            { "│ ", hl = "Special" },
            { "╲ ││\n", hl = "String" },
            { "││", hl = "Special" },
            { "╲╲││\n", hl = "String" },
            { "││ ", hl = "Special" },
            { "╲ │", hl = "String" },
          },
        }
      end,
      function()
        local v = vim.version()
        return {
          align = "center",
          text = {
            {
              string.format("NVIM v%d.%d.%d", v.major, v.minor, v.patch),
              hl = "String",
            },
          },
        }
      end,
      {
        align = "center",
        text = {
          {
            "──────────────────────────────────────────────",
            hl = "NonText",
          },
        },
      },
      {
        align = "center",
        text = { { "Nvim is open source and freely distributable" } },
      },
      {
        align = "center",
        text = { { "https://neovim.io/#chat", hl = "SnacksDashboardDesc" } },
      },
      {
        align = "center",
        text = {
          {
            "──────────────────────────────────────────────",
            hl = "NonText",
          },
        },
      },
      {
        align = "center",
        action = ":lua require('persisted').load()",
        key = "l",
        text = {
          { "type  " },
          { "l", hl = "SnacksDashboardKey" },
          { "  to load session    " },
        },
      },
      {
        align = "center",
        action = ":ene | startinsert",
        key = "n",
        text = {
          { "type  " },
          { "n", hl = "SnacksDashboardKey" },
          { "  to create new file " },
        },
      },
      {
        align = "center",
        action = function()
          vim.cmd("PackSync")
        end,
        key = "U",
        text = {
          { "type  " },
          { "U", hl = "SnacksDashboardKey" },
          { "  to update plugins  " },
        },
      },
      {
        align = "center",
        action = ":qa",
        key = "q",
        text = {
          { "type  " },
          { "q", hl = "SnacksDashboardKey" },
          { "  to exit            " },
        },
      },
      {
        align = "center",
        text = {
          {
            "──────────────────────────────────────────────",
            hl = "NonText",
          },
        },
      },
      {
        align = "center",
        text = { { "Help poor children in Uganda!" } },
      },
      {
        align = "center",
        action = ":help Kuwasha",
        key = "K",
        text = {
          { "type  " },
          { ":", hl = "SpecialKey" },
          { "help Kuwasha", hl = "SnacksDashboardCommand" },
          { "<Enter>", hl = "SpecialKey" },
          { "  for information    " },
        },
      },
    },
  },
  image = {
    enabled = true,
    img_dirs = {
      "~/Documents/Screenshots/",
    },
  },
  indent = {
    enabled = true,
    scope = { enabled = false },
  },
  input = { enabled = true },
  lazygit = {
    theme = {
      [241] = { fg = "Special" },
      activeBorderColor = { fg = "String", bold = true },
      cherryPickedCommitBgColor = { fg = "Identifier" },
      cherryPickedCommitFgColor = { fg = "Function" },
      defaultFgColor = { fg = "Normal" },
      inactiveBorderColor = { fg = "FloatBorder" },
      optionsTextColor = { fg = "Function" },
      searchingActiveBorderColor = { fg = "String", bold = true },
      selectedLineBgColor = { bg = "Visual" }, -- set to `default` to have no background colour
      unstagedChangesColor = { fg = "DiagnosticError" },
    },
  },
  picker = {
    prompt = "> ",
    enabled = true,
    win = {
      input = {
        wo = {
          foldcolumn = "0",
        },
        keys = {
          ["<C-q>"] = { "qflist_append", mode = { "n", "i" } },
        },
      },
      list = {
        wo = {
          foldcolumn = "0",
        },
      },
      preview = {
        wo = {
          foldcolumn = "0",
        },
      },
    },
    actions = {
      qflist_append = function(picker)
        picker:close()
        local sel = picker:selected()
        local items = #sel > 0 and sel or picker:items()
        local qf = {}
        for _, item in ipairs(items) do
          qf[#qf + 1] = {
            filename = Snacks.picker.util.path(item),
            bufnr = item.buf,
            lnum = item.pos and item.pos[1] or 1,
            col = item.pos and item.pos[2] + 1 or 1,
            end_lnum = item.end_pos and item.end_pos[1] or nil,
            end_col = item.end_pos and item.end_pos[2] + 1 or nil,
            text = item.line or item.comment or item.label or item.name or item.detail or item.text,
            pattern = item.search,
            valid = true,
          }
        end
        vim.fn.setqflist(qf, "a")
        vim.cmd("botright copen")
      end,
    },
  },
  notifier = { enabled = true },
  terminal = { enabled = true },
})
