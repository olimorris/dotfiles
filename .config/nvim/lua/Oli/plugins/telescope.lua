local ok, telescope = om.safe_require("telescope")
if not ok then return end

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
        preview_width = 0.6,
        prompt_position = "top",
      },
      width = 0.9,
      height = 0.8,
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
      "__pycache__",
      "%.sqlite3",
      "%.ipynb",
      "vendor",
      "node_modules",
      "dotbot",
    },
    file_sorter = require("telescope.sorters").get_fuzzy_file,
    generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
    file_previewer = require("telescope.previewers").vim_buffer_cat.new,
    grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
    qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,

    -- Mappings
    mappings = {
      i = {
        ["<ESC>"] = require("telescope.actions").close,
        ["<C-e>"] = custom_actions.multi_select,
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
        ["<C-q>"] = require("telescope.actions").send_to_qflist,
      },
      n = {
        ["<ESC>"] = require("telescope.actions").close
      },
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
      -- workspaces = {
      --   ["nvim"] = os.getenv("HOME_DIR") .. ".config/nvim",
      --   ["dots"] = os.getenv("HOME_DIR") .. ".dotfiles",
      --   ["project"] = os.getenv("PROJECT_DIR"),
      --   ["project2"] = os.getenv("OTHER_PROJECT_DIR"),
      -- },
    },
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
})
