require("oil").setup({
  default_file_explorer = false,
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  float = {
    border = "none",
  },
  is_always_hidden = function(name, bufnr)
    return name == ".."
  end,
  keymaps = {
    ["<C-c>"] = false,
    ["q"] = "actions.close",
    [">"] = "actions.toggle_hidden",
    ["<C-y>"] = "actions.copy_entry_path",
    ["gd"] = {
      desc = "Toggle detail view",
      callback = function()
        local oil = require("oil")
        local config = require("oil.config")
        if #config.columns == 1 then
          oil.set_columns({ "icon", "permissions", "size", "mtime" })
        else
          oil.set_columns({ "icon" })
        end
      end,
    },
  },
  buf_options = {
    buflisted = false,
  },
})

require("mini.test").setup()

require("aerial").setup({
  autojump = true,
  close_on_select = true,
  layout = {
    min_width = 30,
  },
})

require("persisted").setup({
  save_dir = Sessiondir .. "/",
  use_git_branch = true,
  autosave = true,
  -- autoload = true,
  -- allowed_dirs = {
  --   "~/Code",
  -- },
  -- on_autoload_no_session = function()
  --   return vim.notify("No session found", vim.log.levels.WARN)
  -- end,
  should_save = function()
    local excluded_filetypes = {
      "alpha",
      "oil",
      "lazy",
      "",
    }

    for _, filetype in ipairs(excluded_filetypes) do
      if vim.bo.filetype == filetype then
        return false
      end
    end

    return true
  end,
})

local overseer = require("overseer")
overseer.setup({
  templates = {
    "builtin",
    "vscode",
  },
})

overseer.register_template({
  name = "Python: Run File",
  builder = function()
    local file = vim.fn.expand("%:p")
    return {
      cmd = { "python" },
      args = { file },
      components = { { "open_output", direction = "dock", focus = true }, "default" },
    }
  end,
  condition = {
    filetype = { "python" },
  },
})
