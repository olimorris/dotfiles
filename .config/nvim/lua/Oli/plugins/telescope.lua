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
    dynamic_preview_title = true,

    sorting_strategy = "ascending",
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
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
        height = 0.9,
        preview_height = 0.4,
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
