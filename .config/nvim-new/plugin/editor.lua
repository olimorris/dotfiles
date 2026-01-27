require("nvim-surround").setup()

require("oil").setup({
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  float = {
    border = "single",
  },
  keymaps = {
    ["<C-c>"] = false,
    ["q"] = "actions.close",
    [">"] = "actions.toggle_hidden",
    ["Y"] = { "actions.yank_entry", opts = { modify = ":~" } },
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
  should_save = function()
    -- Don't save if there are no meaningful buffers open
    local bufs = vim.tbl_filter(function(b)
      if
        vim.bo[b].buftype ~= ""
        or vim.tbl_contains({ "codecompanion", "gitcommit", "gitrebase", "jj" }, vim.bo[b].filetype)
      then
        return false
      end
      return vim.api.nvim_buf_get_name(b) ~= ""
    end, vim.api.nvim_list_bufs())
    if #bufs < 1 then
      return false
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
