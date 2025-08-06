vim.pack.add({
  { src = "https://github.com/folke/edgy.nvim" },
  { src = "https://github.com/folke/snacks.nvim" },
  { src = "https://github.com/rebelot/heirline.nvim" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/folke/todo-comments.nvim" },
  { src = "https://github.com/nmac427/guess-indent.nvim" },
  { src = "https://github.com/lukas-reineke/virt-column.nvim" },
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
})

--=============================================================================
-- Plugin Setup
--=============================================================================
require("heirline").setup({
  winbar = require("plugins.ui.winbar"),
  statusline = require("plugins.ui.statusline"),
  statuscolumn = require("plugins.ui.statuscolumn"),
  opts = {
    disable_winbar_cb = function(args)
      local conditions = require("heirline.conditions")

      return conditions.buffer_matches({
        buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
        filetype = { "alpha", "codecompanion", "oil", "lspinfo", "snacks_dashboard", "toggleterm" },
      }, args.buf)
    end,
  },
})

require("todo-comments").setup({
  signs = false,
  highlight = {
    keyword = "bg",
  },
  keywords = {
    FIX = { icon = " " }, -- Custom fix icon
  },
})

require("guess-indent").setup({})

require("render-markdown").setup({
  completions = { blink = { enabled = true } },
  file_types = { "codecompanion", "markdown" },
  overrides = {
    filetype = {
      codecompanion = {
        html = {
          tag = {
            buf = { icon = " ", highlight = "CodeCompanionChatIcon" },
            file = { icon = " ", highlight = "CodeCompanionChatIcon" },
            group = { icon = " ", highlight = "CodeCompanionChatIcon" },
            help = { icon = "󰘥 ", highlight = "CodeCompanionChatIcon" },
            image = { icon = " ", highlight = "CodeCompanionChatIcon" },
            symbols = { icon = " ", highlight = "CodeCompanionChatIcon" },
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

require("edgy").setup({
  animate = { enabled = false },
  options = {
    top = { size = 10 },
  },
  bottom = {
    {
      ft = "snacks_terminal",
      size = { height = om.on_big_screen() and 20 or 0.2 },
      title = "Terminal %{b:snacks_terminal.id}",
      filter = function(_buf, win)
        return vim.w[win].snacks_win
          and vim.w[win].snacks_win.position == "bottom"
          and vim.w[win].snacks_win.relative == "editor"
          and not vim.w[win].trouble_preview
      end,
    },
    { ft = "qf", title = "QuickFix" },
    {
      ft = "help",
      size = { height = 20 },
      -- only show help buffers
      filter = function(buf)
        return vim.bo[buf].buftype == "help"
      end,
    },
    { title = "Neotest Output", ft = "neotest-output-panel", size = { height = 15 } },
  },
  right = {
    { ft = "aerial", title = "Symbols", size = { width = 0.3 } },
    { ft = "neotest-summary", title = "Neotest Summary", size = { width = 0.3 } },
    { ft = "oil", title = "File Explorer", size = { width = 0.3 } },
  },
})

require("virt-column").setup({
  char = "│",
  highlight = "VirtColumn",
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
    preset = {
      keys = {
        { icon = " ", key = "l", desc = "Load Session", action = ":lua require('persisted').load()" },
        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
        { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
        { icon = "󱘣 ", key = "s", desc = "Search Files", action = ":lua Snacks.dashboard.pick('live_grep')" },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
    },
    sections = {
      {
        section = "terminal",
        cmd = "lolcat --seed=24 ~/.config/nvim/static/neovim.cat",
        indent = -5,
        height = 9,
        width = 69,
        padding = 1,
      },
      {
        section = "keys",
        indent = 1,
        padding = 1,
      },
      {
        align = "center",
        text = {
          { "⚡️ Neovim loaded ", hl = "SnacksDashboardFooterText" },
          { tostring(#vim.pack.get() + 3), hl = "SnacksDashboardFooterEmphasis" },
          { " plugins", hl = "SnacksDashboardFooterText" },
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

--=============================================================================
-- Keymaps
--=============================================================================
local opts = { noremap = true, silent = true }

om.set_keymaps("<Leader>t", function()
  require("snacks").picker.todo_comments()
end, "n", opts)
om.set_keymaps("<C-x>", function()
  Snacks.terminal.toggle()
end, { "n", "t" }, opts)
om.set_keymaps("<C-c>", function()
  Snacks.bufdelete()
end, "n", opts)
om.set_keymaps("<C-f>", function()
  Snacks.picker.files({ hidden = true })
end, "n", opts)
om.set_keymaps("<C-b>", function()
  Snacks.picker.buffers()
end, "n", opts)
om.set_keymaps("<C-g>", function()
  Snacks.picker.grep_buffers()
end, "n", opts)
om.set_keymaps("<Leader>g", function()
  Snacks.picker.grep()
end, "n", opts)
om.set_keymaps("<Leader><Leader>", function()
  Snacks.picker.recent()
end, "n", opts)
om.set_keymaps("<Leader>h", function()
  Snacks.picker.notifications()
end, "n", opts)
om.set_keymaps("<LocalLeader>gb", function()
  Snacks.gitbrowse()
end, "n", opts)
om.set_keymaps("<LocalLeader>u", function()
  Snacks.picker.undo()
end, "n", opts)
om.set_keymaps("<Leader>l", function()
  Snacks.lazygit()
end, "n", opts)

om.set_keymaps("<Esc>", "<C-\\><C-n>", "t", vim.list_extend(opts, { nowait = true }))
