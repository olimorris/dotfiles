return {
  "nvim-tree/nvim-web-devicons",
  {
    "lewis6991/satellite.nvim",
    config = true,
  },
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    init = function() vim.opt.splitkeep = "screen" end,
    opts = {
      animate = { enabled = false },
      bottom = {
        {
          ft = "lazyterm",
          title = "Terminal",
          size = { height = om.on_big_screen() and 20 or 0.2 },
          filter = function(buf) return not vim.b[buf].lazyterm_cmd end,
        },
        { ft = "qf", title = "QuickFix" },
        {
          ft = "help",
          size = { height = 20 },
          -- only show help buffers
          filter = function(buf) return vim.bo[buf].buftype == "help" end,
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
    config = true,
  },
  {
    "tzachar/local-highlight.nvim", -- Highlight word under cursor throughout the visible buffer
    opts = {
      file_types = { "lua", "javascript", "python", "ruby" },
    },
  },
  {
    "stevearc/dressing.nvim", -- Utilises Neovim UI hooks to manage inputs, selects etc
    opts = {
      input = {
        default_prompt = "> ",
        relative = "editor",
        prefer_width = 50,
        prompt_align = "center",
        win_options = { winblend = 0 },
      },
      select = {
        get_config = function(opts)
          opts = opts or {}
          local config = {
            telescope = {
              layout_config = {
                width = 0.8,
              },
            },
          }
          if opts.kind == "legendary.nvim" then
            config.telescope.sorter = require("telescope.sorters").fuzzy_with_index_bias({})
          end
          return config
        end,
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim", -- Git signs in the statuscolumn
    opts = {
      signs = {
        add = { hl = "GitSignsAdd", text = "▌" },
        change = { hl = "GitSignsChange", text = "▌" },
        delete = { hl = "GitSignsDelete", text = "▁" },
        topdelete = { hl = "GitSignsDelete", text = "▔" },
        changedelete = { hl = "GitSignsChange", text = "▁" },
        untracked = { hl = "GitSignsUntracked", text = "▌" },
      },
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
    "lukas-reineke/indent-blankline.nvim", -- Show indentation lines
    opts = {
      use_treesitter = true,
      show_first_indent_level = false,
      show_trailing_blankline_indent = false,

      -- filetype_exclude = filetypes_to_exclude,
      buftype_exclude = { "terminal", "nofile" },
    },
  },
  {
    "goolord/alpha-nvim", -- Dashboard for Neovim
    priority = 5, -- Load after persisted.nvim
    init = function()
      require("legendary").commands({
        {
          ":Alpha",
          description = "Show the Alpha dashboard",
        },
      })
    end,
    config = function()
      local alpha = require("alpha")

      require("alpha.term")
      local dashboard = require("alpha.themes.dashboard")

      -- Terminal header
      dashboard.section.terminal.command = "cat | lolcat --seed=24 "
        .. os.getenv("HOME")
        .. "/.config/nvim/static/neovim.cat"
      dashboard.section.terminal.width = 69
      dashboard.section.terminal.height = 8

      local function button(sc, txt, keybind, keybind_opts)
        local b = dashboard.button(sc, txt, keybind, keybind_opts)
        b.opts.hl = "AlphaButtonText"
        b.opts.hl_shortcut = "AlphaButtonShortcut"
        return b
      end

      dashboard.section.buttons.val = {
        button("l", "   Load session", "<cmd>lua require('persisted').load()<CR>"),
        button("n", "   New file", "<cmd>ene <BAR> startinsert <CR>"),
        button("r", "   Recent files", "<cmd>Telescope frecency workspace=CWD<CR>"),
        button("f", "   Find file", "<cmd>Telescope find_files hidden=true path_display=smart<CR>"),
        button("s", "󱘣   Search files", "<cmd>Telescope live_grep path_display=smart<CR>"),
        -- button("p", "   Projects", "<cmd>Telescope projects<CR>"),
        button("u", "   Update plugins", "<cmd>lua require('lazy').sync()<CR>"),
        button("q", "   Quit Neovim", "<cmd>qa!<CR>"),
      }
      dashboard.section.buttons.opts = {
        spacing = 0,
      }

      -- Footer
      local function footer()
        local total_plugins = require("lazy").stats().count
        local version = vim.version()
        local nvim_version_info = "  Neovim v" .. version.major .. "." .. version.minor .. "." .. version.patch

        return " " .. total_plugins .. " plugins" .. nvim_version_info
      end

      dashboard.section.footer.val = footer()
      dashboard.section.footer.opts.hl = "AlphaFooter"

      -- Layout
      if om.on_big_screen() then
        dashboard.config.layout = {
          { type = "padding", val = 5 },
          dashboard.section.terminal,
          { type = "padding", val = 5 },
          dashboard.section.buttons,
          { type = "padding", val = 2 },
          dashboard.section.footer,
        }
      else
        dashboard.config.layout = {
          { type = "padding", val = 1 },
          dashboard.section.terminal,
          { type = "padding", val = 2 },
          dashboard.section.buttons,
          { type = "padding", val = 1 },
          dashboard.section.footer,
        }
      end

      dashboard.config.opts.noautocmd = false

      alpha.setup(dashboard.opts)
    end,
  },
}
