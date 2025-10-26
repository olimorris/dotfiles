local api = vim.api
local autocmd = api.nvim_create_autocmd --[[@type function]]

---Helper to create augroups
---@param name string
local function augroup(name)
  return api.nvim_create_augroup(name, { clear = true })
end

-- ConcealAttributes
autocmd({ "BufEnter", "BufWritePost", "TextChanged", "InsertLeave" }, {
  group = augroup("dotfiles.concealattributes"),
  pattern = "*.html",
  callback = function()
    vim.opt.conceallevel = 2
  end,
})

-- CodeCompanion
local cc = augroup("dotfiles.codecompanion")
autocmd("User", {
  group = cc,
  pattern = "CodeCompanionInlineFinished",
  callback = function()
    vim.lsp.buf.format()
  end,
})

autocmd("User", {
  group = cc,
  pattern = "CodeCompanionChatCreated",
  callback = function(args)
    vim.treesitter.start(args.data.bufnr, "markdown")
  end,
})

-- Heirline
-- autocmd("User", {
--   group = augroup("Heirline"),
--   pattern = "HeirlineInitWinbar",
--   callback = function(args)
--     local buf = args.buf
--     local buftype = vim.tbl_contains({ "prompt", "nofile", "help", "quickfix" }, vim.bo[buf].buftype)
--     local filetype = vim.tbl_contains({ "", "alpha", "gitcommit", "fugitive" }, vim.bo[buf].filetype)
--     if buftype or filetype then
--       vim.opt_local.winbar = nil
--     end
--   end,
-- })

-- GitTrackRemoteBranch
local git_group = augroup("dotfiles.git_track_remote_branch")
autocmd("TermLeave", {
  group = git_group,
  pattern = "*",
  callback = function()
    om.GitRemoteSync()
  end,
})
autocmd("VimEnter", {
  group = git_group,
  pattern = "*",
  callback = function()
    if _G.om.on_personal then
      local timer = vim.loop.new_timer()
      timer:start(0, 120000, function()
        om.GitRemoteSync()
      end)
    end
  end,
})

local filetype_group = augroup("dotfiles.filetypes")
autocmd("FileType", {
  group = filetype_group,
  pattern = { "checkhealth", "help", "lspinfo", "netrw", "qf", "query" },
  callback = function()
    vim.keymap.set("n", "q", vim.cmd.close, { desc = "Close the current buffer", buffer = true })
  end,
})
autocmd("FileType", {
  group = filetype_group,
  pattern = "markdown",
  callback = function()
    vim.cmd("setlocal wrap linebreak formatoptions-=t")
  end,
})
autocmd("FileType", {
  group = filetype_group,
  pattern = "json",
  callback = function()
    vim.keymap.set("n", "o", function()
      local line = api.nvim_get_current_line()
      local should_add_comma = string.find(line, "[^,{[]$")
      if should_add_comma then
        return "A,<cr>"
      else
        return "o"
      end
    end, { buffer = true, expr = true })
  end,
})
autocmd("FileType", {
  group = filetype_group,
  pattern = { "tex", "latex", "plaintex" },
  callback = function()
    vim.opt_local.ft = "tex"

    -- Visual behavior
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true

    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.colorcolumn = "80"
    vim.opt_local.conceallevel = 2 -- Enable concealment
    vim.opt_local.concealcursor = "" -- Don't conceal under cursor

    -- Hard-wrap / formatting
    vim.opt_local.textwidth = 80
  end,
})

autocmd("FileType", {
  group = filetype_group,
  pattern = { "html", "vue" },
  callback = function()
    vim.keymap.set("i", "=", function()
      local cursor = api.nvim_win_get_cursor(0)
      local left_of_cursor_range = { cursor[1] - 1, cursor[2] - 1 }
      local node = vim.treesitter.get_node({ pos = left_of_cursor_range })
      local nodes_active_in = { "attribute_name", "directive_argument", "directive_name" }
      if not node or not vim.tbl_contains(nodes_active_in, node:type()) then
        return "="
      end
      return '=""<left>'
    end, { expr = true, buffer = true })
  end,
})

autocmd("TermOpen", {
  group = augroup("dotfiles.terminal"),
  pattern = "term://*",
  callback = function()
    if vim.bo.filetype == "" or vim.bo.filetype == "toggleterm" then
      local opts = { silent = false, buffer = 0 }
      vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
    end
  end,
})

autocmd("BufWritePre", {
  group = augroup("dotfiles.remove_trailing_whitespace"),
  pattern = "*",
  callback = function()
    vim.cmd([[%s/\s\+$//e]])
  end,
})

autocmd("TextYankPost", {
  group = augroup("dotfiles.highlight_yanked_text"),
  pattern = "*",
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- autocmd("User", {
--   pattern = "CodeCompanionChatOpened",
--   callback = function()
--     local end_time = vim.uv.hrtime() - _G.cc_start_time
--     print("Chat opened after " .. end_time / 1e6 .. " ms")
--   end,
-- })
