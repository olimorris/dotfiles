local ok, telescope = om.safe_require("telescope")
if not ok then
  return
end

telescope.setup({
  defaults = {
    -- Appearance
    entry_prefix = "  ",
    prompt_prefix = "   ",
    selection_caret = "  ",
    color_devicons = true,
    path_display = { "smart" },

    sorting_strategy = "ascending",
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
        prompt_position = "top",
        preview_width = 0.55,
        results_width = 0.8,
      },
      vertical = { mirror = false },
      width = 0.87,
      height = 0.80,
      preview_cutoff = 50,
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
      "__pycache__/*",
      "%.sqlite3",
      "%.ipynb",
      "vendor/*",
      "node_modules/*",
    },
    file_sorter = require("telescope.sorters").get_fuzzy_file,
    generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
    file_previewer = require("telescope.previewers").vim_buffer_cat.new,
    grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
    qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,

    -- Telescope smart history
    history = {
      path = '~/.local/share/nvim/databases/telescope_history.sqlite3',
      limit = 100,
    },

    -- Mappings
    mappings = {
      i = {
        ["<ESC>"] = require("telescope.actions").close,
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
        ["<C-q>"] = require("telescope.actions").send_to_qflist,
      },
      n = { ["<ESC>"] = require("telescope.actions").close },
    },
  },

  extensions = {
    frecency = {
      show_scores = false,
      show_unindexed = true,
      ignore_patterns = {
        "*.git/*",
        "*/tmp/*",
        "*/node_modules/*",
        "*/vendor/*",
      },
      workspaces = {
        ["nvim"] = os.getenv("HOME_DIR") .. ".config/nvim",
        ["dots"] = os.getenv("HOME_DIR") .. ".dotfiles",
        ["project"] = os.getenv("PROJECT_DIR"),
        ["project2"] = os.getenv("OTHER_PROJECT_DIR"),
      },
    },
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = false, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    },
    project = { base_dirs = { { path = os.getenv("PROJECTS_DIR") } } },
  },
})
