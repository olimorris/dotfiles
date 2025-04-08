return {
  "nvim-tree/nvim-web-devicons",
  {
    "MeanderingProgrammer/render-markdown.nvim", -- Make Markdown buffers look beautiful
    ft = { "markdown", "codecompanion" },
    opts = {
      render_modes = true, -- Render in ALL modes
      sign = {
        enabled = false, -- Turn off in the status column
      },
    },
  },
  {
    "folke/edgy.nvim", -- Create predefined window layouts
    event = "VeryLazy",
    init = function()
      vim.opt.laststatus = 3
      vim.opt.splitkeep = "screen"
    end,
    opts = {
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
    },
  },
  {
    "lukas-reineke/virt-column.nvim", -- Use characters in the color column
    opts = {
      char = "│",
      highlight = "VirtColumn",
    },
  },
  {
    "lewis6991/gitsigns.nvim", -- Git signs in the statuscolumn
    opts = {
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
    },
  },
  {
    "NvChad/nvim-colorizer.lua", -- Highlight hex and rgb colors within Neovim
    cmd = "ColorizerToggle",
    init = function()
      require("legendary").commands({
        {
          ":ColorizerToggle",
          description = "Colorizer toggle",
        },
      })
    end,
    opts = {
      filetypes = {
        "css",
        eruby = { mode = "foreground" },
        html = { mode = "foreground" },
        "lua",
        "javascript",
        "vue",
      },
    },
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
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
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = "󱘣 ", key = "s", desc = "Search Files", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        sections = {
          {
            section = "terminal",
            cmd = "lolcat --seed=24 ~/.config/nvim/static/neovim.cat",
            indent = -5,
            height = 8,
            width = 69,
            padding = 1,
          },
          {
            section = "keys",
            indent = 1,
            padding = 1,
          },
          { section = "startup" },
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
      picker = { enabled = true },
      notifier = { enabled = true },
      terminal = { enabled = true },
    },
    keys = {
      {
        "<C-c>",
        function()
          Snacks.bufdelete()
        end,
        desc = "Delete Buffer",
      },
      {
        "<C-f>",
        function()
          Snacks.picker.files({ hidden = true })
        end,
        desc = "Find Files",
      },
      {
        "<C-b>",
        function()
          Snacks.picker.buffers()
        end,
        desc = "List Buffers",
      },
      {
        "<C-g>",
        function()
          Snacks.picker.grep_buffers()
        end,
        desc = "Search Open Buffers",
      },
      {
        "<Leader>g",
        function()
          Snacks.picker.grep()
        end,
        desc = "Search Files",
      },
      {
        "<Leader><Leader>",
        function()
          Snacks.picker.recent()
        end,
        desc = "List Recent Files",
      },
      {
        "<Leader>h",
        function()
          Snacks.picker.notifications()
        end,
        desc = "Show Notifications",
      },
      {
        "<LocalLeader>gb",
        function()
          Snacks.gitbrowse()
        end,
        desc = "Git Browse",
      },
      {
        "<LocalLeader>u",
        function()
          Snacks.picker.undo()
        end,
        desc = "Undo History",
      },
      {
        "<C-x>",
        function()
          Snacks.terminal.toggle()
        end,
        mode = { "n", "t" },
        desc = "Toggle Terminal",
      },
    },
    init = function(config)
      local snacks = require("snacks")

      local keymaps = {
        {
          "<Esc>",
          "<C-\\><C-n>",
          description = "Escape means escape in the terminal",
          hide = true,
          mode = { "t" },
          opts = { nowait = true },
        },
      }

      for _, direction in ipairs({ "h", "j", "k", "l" }) do
        table.insert(keymaps, {
          "<C-" .. direction .. ">",
          "<C-" .. direction .. ">",
          description = "Navigate in direction " .. direction,
          mode = { "t" },
          opts = { nowait = true },
        })
      end

      require("legendary").keymaps(keymaps)
      require("legendary").commands({
        {
          "LazyGit",
          function()
            snacks.lazygit()
          end,
          description = "Open LazyGit in a floating window",
        },
      })
    end,
  },
}
