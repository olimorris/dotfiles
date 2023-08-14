return {
  {
    "nvim-telescope/telescope.nvim", -- Awesome fuzzy finder for everything
    lazy = true,
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "debugloop/telescope-undo.nvim", -- Visualise undotree
        init = function()
          require("legendary").keymaps({
            { "<LocalLeader>u", "<cmd>Telescope undo<CR>", description = "Telescope undo" },
          })
        end,
      },
      {
        "nvim-telescope/telescope-fzf-native.nvim", -- Use fzf within Telescope
        build = "make",
      },
      {
        "nvim-telescope/telescope-frecency.nvim", -- Get frequently opened files
        dependencies = {
          "kkharji/sqlite.lua",
        },
      },
    },
    init = function()
      local t = require("legendary.toolbox")
      require("legendary").keymaps({
        {
          itemgroup = "Telescope",
          description = "Gaze deeply into unknown regions using the power of the moon",
          icon = "",
          keymaps = {
            {
              "<C-f>",
              t.lazy_required_fn("telescope.builtin", "find_files", { hidden = true }),
              description = "Find files",
            },
            {
              "<C-g>",
              t.lazy_required_fn(
                "telescope.builtin",
                "live_grep",
                { prompt_title = "Open Files", path_display = { "shorten" }, grep_open_files = true }
              ),
              description = "Find in open files",
            },
            {
              "<Leader>g",
              t.lazy_required_fn("telescope.builtin", "live_grep", { prompt_title = "Search CWD", path_display = { "smart" } }),
              description = "Search CWD",
            },
            {
              "<C-b>",
              t.lazy_required_fn("telescope.builtin", "buffers", { prompt_title = "Buffer List", path_display = { "smart" } }),
              description = "List buffers",
            },
            {
              "<Leader><Leader>",
              "<cmd>lua require('telescope').extensions.frecency.frecency({ prompt_title = 'Recent Files', workspace = 'CWD' })<CR>",
              description = "Find recent files",
            },
          },
        },
      })
    end,
    config = function()
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      local custom_actions = {}

      function custom_actions.multi_select(prompt_bufnr)
        local function get_table_size(t)
          local count = 0
          for _ in pairs(t) do
            count = count + 1
          end
          return count
        end

        local picker = action_state.get_current_picker(prompt_bufnr)
        local num_selections = get_table_size(picker:get_multi_selection())

        if num_selections > 1 then
          actions.send_selected_to_qflist(prompt_bufnr)
          actions.open_qflist()
        else
          actions.file_edit(prompt_bufnr)
        end
      end

      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          -- Appearance
          entry_prefix = "  ",
          prompt_prefix = "   ",
          selection_caret = "  ",
          color_devicons = true,
          path_display = { "smart" },
          dynamic_preview_title = true,

          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              height = om.on_big_screen() and 0.6 or 0.95,
              preview_width = 0.55,
              prompt_position = "top",
              width = 0.9,
            },
            center = {
              anchor = "N",
              width = 0.9,
              preview_cutoff = 10,
            },
            vertical = {
              height = om.on_big_screen() and 0.4 or 0.9,
              preview_height = 0.3,
              width = 0.9,
              preview_cutoff = 10,
              prompt_position = "top",
            },
          },

          -- Searching
          set_env = { COLORTERM = "truecolor" },
          file_ignore_patterns = {
            ".git/",
            "%.csv",
            "%.jpg",
            "%.jpeg",
            "%.png",
            "%.svg",
            "%.otf",
            "%.ttf",
            "%.lock",
            "__pycache__",
            "%.sqlite3",
            "%.ipynb",
            "vendor",
            "node_modules",
            "dotbot",
          },
          file_sorter = require("telescope.sorters").get_fuzzy_file,

          -- Mappings
          mappings = {
            i = {
              ["<esc>"] = require("telescope.actions").close,
              ["<C-e>"] = custom_actions.multi_select,
              ["<C-c>"] = require("telescope.actions").delete_buffer,
              ["<C-j>"] = require("telescope.actions").move_selection_next,
              ["<C-d>"] = require("telescope.actions").preview_scrolling_down,
              ["<C-f>"] = require("telescope.actions").preview_scrolling_up,
              ["<C-k>"] = require("telescope.actions").move_selection_previous,
              ["<C-q>"] = require("telescope.actions").send_to_qflist,
            },
            n = {
              ["q"] = require("telescope.actions").close,
              ["<C-n>"] = require("telescope.actions").move_selection_next,
              ["<C-p>"] = require("telescope.actions").move_selection_previous,
            },
          },
        },

        extensions = {
          frecency = {
            show_scores = false,
            show_unindexed = false,
            ignore_patterns = {
              "*.git/*",
              "*/tmp/*",
              "*/node_modules/*",
              "*/vendor/*",
            },
            -- workspaces = {
            --   ["nvim"] = os.getenv("HOME_DIR") .. ".config/nvim",
            --   ["dots"] = os.getenv("HOME_DIR") .. ".dotfiles",
            --   ["project"] = os.getenv("PROJECT_DIR"),
            -- },
          },
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          undo = {
            mappings = {
              i = {
                ["<CR>"] = require("telescope-undo.actions").restore,
                ["<C-a>"] = require("telescope-undo.actions").yank_additions,
                ["<C-d>"] = require("telescope-undo.actions").yank_deletions,
              },
            },
          },
        },
      })

      -- Extensions
      telescope.load_extension("fzf")
      telescope.load_extension("undo")
      telescope.load_extension("aerial")
      telescope.load_extension("frecency")
      telescope.load_extension("persisted")
      telescope.load_extension("refactoring")
    end,
  },
}
