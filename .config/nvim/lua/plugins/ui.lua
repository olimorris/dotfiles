return {
  "nvim-tree/nvim-web-devicons",
  {
    "nmac427/guess-indent.nvim", -- Automatically detects which indents should be used in the current buffer
    opts = {},
  },
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
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
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
            height = 9,
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
      {
        "<Leader>l",
        function()
          Snacks.lazygit()
        end,
        desc = "Open LazyGit",
      },
      {
        "<Esc>",
        "<C-\\><C-n>",
        mode = "t",
        desc = "Escape means escape",
        nowait = true,
      },
    },
  },
  {
    "hat0uma/csvview.nvim", -- Make CSV files great again
    opts = {
      parser = { comments = { "#", "//" } },
      keymaps = {
        -- Text objects for selecting fields
        textobject_field_inner = { "if", mode = { "o", "x" } },
        textobject_field_outer = { "af", mode = { "o", "x" } },
        -- Excel-like navigation:
        -- Use <Tab> and <S-Tab> to move horizontally between fields.
        -- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
        -- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
        jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
        jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
        jump_next_row = { "<Enter>", mode = { "n", "v" } },
        jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
      },
    },
    cmd = { "Csv", "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
    init = function()
      om.create_user_command("Csv", "Toggle CSV view", function()
        require("csvview").toggle(0, {
          parser = {
            delimiter = ",",
            quote_char = '"',
            comment_char = "#",
          },
          view = {
            display_mode = "border",
            header_lnum = 1,
          },
        })
      end)
    end,
  },
}
