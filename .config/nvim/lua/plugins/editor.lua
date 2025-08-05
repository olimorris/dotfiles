vim.pack.add({
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/kevinhwang91/nvim-bqf" },
  { src = "https://github.com/stevearc/aerial.nvim" },
  { src = "https://github.com/bassamsdata/namu.nvim" },
  { src = "file:///Users/Oli/Code/Neovim/persisted.nvim" },
})

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

require("namu").setup({
  namu_symbols = {
    enable = true,
    options = {}, -- here you can configure namu
  },
  ui_select = { enable = false }, -- vim.ui.select() wrapper
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

--=============================================================================
-- Keymaps
--=============================================================================
local opts = { noremap = true, silent = true }

om.set_keymaps("_", function()
  require("oil").toggle_float(vim.fn.getcwd())
end, "n", opts)
om.set_keymaps("-", function()
  require("oil").toggle_float()
end, "n", opts)

om.set_keymaps("<C-t>", function()
  require("namu.namu_symbols").show()
end, { "n", "x", "o" }, opts)
om.set_keymaps("<C-e>", function()
  require("namu.namu_workspace").show()
end, { "n", "x", "o" }, opts)

--=============================================================================
-- Commands
--=============================================================================
om.create_user_command("Sessions", "List Sessions", function()
  require("persisted").select()
end)
