local keymap = vim.keymap.set --[[@type function]]
local opts = { noremap = true, silent = true }

keymap("n", "<C-q>", "<cmd>q<CR>", { silent = true, desc = "Quit Neovim" })
keymap("t", "<Esc>", "<C-\\><C-n>", vim.tbl_extend("force", opts, { nowait = true, desc = "Exit terminal mode" }))

-- Buffers
keymap("n", "<C-y>", "<cmd>%y+<CR>", { desc = "Copy buffer" })
keymap("n", "<C-s>", "<cmd>silent write<CR>", { desc = "Save buffer" })
keymap("i", "<C-s>", "<cmd>silent write<CR>", { desc = "Save buffer" })
keymap("n", "<Tab>", "<cmd>bnext<CR>", { noremap = false, desc = "Next buffer" })
keymap("n", "<S-Tab>", "<cmd>bprev<CR>", { noremap = false, desc = "Previous buffer" })

-- Movement
keymap({ "n", "x", "o" }, "<S-h>", "^", { noremap = true, silent = true, desc = "Move to first non-blank in line" })
keymap({ "n", "x", "o" }, "<S-l>", "g_", { noremap = true, silent = true, desc = "Move to last non-blank in line" })
keymap("n", "<A-k>", ":m .-2<CR>==", { desc = "Move selection up", silent = true })
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })
keymap("n", "<A-j>", ":m .+1<CR>==", { desc = "Move selection down", silent = true })
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })

-- Editing words
keymap("n", "<LocalLeader>,", "<cmd>norm A,<CR>", { desc = "Append comma" })
keymap("n", "<LocalLeader>;", "<cmd>norm A;<CR>", { desc = "Append semicolon" })

-- Wrap text
keymap("v", '<LocalLeader>"', [[c"<c-r>""<esc>]], { desc = 'Wrap text in quotes ""' })
keymap("n", '<LocalLeader>"', [[ciw"<c-r>""<esc>]], { desc = 'Wrap text in quotes ""' })
keymap("v", "<LocalLeader>(", [[c(<c-r>")<esc>]], { desc = "Wrap text in brackets ()" })
keymap("n", "<LocalLeader>(", [[ciw(<c-r>")<esc>]], { desc = "Wrap text in brackets ()" })
keymap("v", "<LocalLeader>{", [[c{<c-r>"}<esc>]], { desc = "Wrap text in curly braces {}" })
keymap("n", "<LocalLeader>{", [[ciw{<c-r>"}<esc>]], { desc = "Wrap text in curly braces {}" })
keymap("v", "<LocalLeader>[", [[c[<c-r>"]<esc>]], { desc = "Wrap text in square braces []" })
keymap("n", "<LocalLeader>[", [[ciw[<c-r>"]<esc>]], { desc = "Wrap text in square braces []" })

-- Find and replace
keymap("n", "<LocalLeader>fl", [[:s/\<<C-r>=expand("<cword>")<CR>\>/]], { desc = "Replace cursor words in line" })
keymap("n", "<LocalLeader>fw", [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]], { desc = "Replace cursor words in buffer" })

-- Working with lines
keymap("n", "<CR>", "o<Esc>", { desc = "Insert blank line below" })
keymap("n", "<S-CR>", "O<Esc>", { desc = "Insert blank line above" })

-- Splits
keymap("n", "<Leader>-", "<cmd>split<CR>", { desc = "Split: Create Horizontal" })
keymap("n", "<Leader>\\", "<cmd>vsplit<CR>", { desc = "Split: Create Vertical" })
keymap("n", "<C-k>", "<cmd>wincmd k<CR>", { desc = "Split: Move up" })
keymap("n", "<C-j>", "<cmd>wincmd j<CR>", { desc = "Split: Move down" })
keymap("n", "<C-h>", "<cmd>wincmd h<CR>", { desc = "Split: Move left" })
keymap("n", "<C-l>", "<cmd>wincmd l<CR>", { desc = "Split: Move right" })
keymap("n", "<Leader>c", "<cmd>wincmd q<CR>", { desc = "Split: Close" })
keymap("n", "<Leader>s", "<cmd>wincmd o<CR>", { desc = "Split: Close all but current" })

-- nvim-surround
keymap("x", "(", "S)", { remap = true, desc = "Surround with ()'s" })
keymap("x", ")", "S)", { remap = true, desc = "Surround with ()'s" })
keymap("x", "{", "S}", { remap = true, desc = "Surround with {}'s" })
keymap("x", "}", "S}", { remap = true, desc = "Surround with {}'s" })
keymap("x", "[", "S]", { remap = true, desc = "Surround with []'s" })
keymap("x", "]", "S]", { remap = true, desc = "Surround with []'s" })

-- Misc
keymap("v", ">", ">gv", { desc = "Indent" })
keymap("v", "<", "<gv", { desc = "Outdent" })
keymap("n", "<Esc>", "<cmd>:noh<CR>", { desc = "Clear searches" })

keymap("n", "<Leader>rt", "<cmd>restart<CR>", { desc = "Restart Neovim" })

-- Pack
keymap("n", "<leader>ps", function()
  vim.cmd("PackSync")
end, { desc = "Sync plugins" })

-- LSP
keymap("n", "gq", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format" })
keymap("n", "gd", function()
  Snacks.picker.lsp_definitions()
end, { desc = "Go to definition", noremap = true, silent = true })
keymap("n", "gr", function()
  Snacks.picker.lsp_references()
end, { desc = "Find references", noremap = true, silent = true })
keymap("n", "gf", function()
  Snacks.picker.diagnostics_buffer()
end, { desc = "Find diagonostics", noremap = true, silent = true })
keymap("n", "[", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Go to previous diagnostic item" })
keymap("n", "]", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Go to next diagnostic item" })

-- Testing
keymap("n", "<LocalLeader>tn", function()
  if vim.bo.filetype == "lua" then
    return require("mini.test").run_at_location()
  end
end, { desc = "Run test at location", nowait = true })
keymap("n", "<LocalLeader>tf", function()
  if vim.bo.filetype == "lua" then
    return require("mini.test").run_file()
  end
end, { desc = "Run tests in file", nowait = true })
keymap("n", "<LocalLeader>tl", function()
  if vim.bo.filetype == "lua" then
    return require("mini.test").run_last()
  end
end, { desc = "Run all tests", nowait = true })
keymap("n", "<LocalLeader>ts", function()
  if vim.bo.filetype == "lua" then
    return require("mini.test").run_suite()
  end
end, { desc = "Run tests in suite", nowait = true })

-- Tree-sitter
keymap({ "x", "o" }, "af", function()
  require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
end, { desc = "Select around function" })
keymap({ "x", "o" }, "if", function()
  require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
end, { desc = "Select inside function" })
keymap({ "x", "o" }, "ac", function()
  require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
end, { desc = "Select around class" })
keymap({ "x", "o" }, "ic", function()
  require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
end, { desc = "Select inside class" })
keymap({ "x", "o" }, "as", function()
  require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
end, { desc = "Select local scope" })

-- CodeCompanion
keymap({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<CR>")
keymap({ "n", "v" }, "<Leader>a", "<cmd>CodeCompanionChat Toggle<CR>")
keymap("v", "<LocalLeader>a", "<cmd>CodeCompanionChat Add<CR>")

-- Inline completions
keymap("i", "<C-a>", vim.lsp.inline_completion.get, opts)
keymap("i", "<C-f>", function()
  require("codecompanion").inline_accept_word()
end, opts)
keymap("i", "<C-l>", function()
  require("codecompanion").inline_accept_line()
end, opts)
-- vim.keymap.set("i", "<C-f>", vim.lsp.inline_completion.get, { desc = "LSP: accept inline completion" })
vim.keymap.set("i", "<C-g>", vim.lsp.inline_completion.select, { desc = "LSP: switch inline completion" })

-- Snacks
keymap("n", "<Leader>t", function()
  require("snacks").picker.todo_comments()
end, opts)
keymap({ "n", "t" }, "<C-x>", function()
  Snacks.terminal.toggle()
end, opts)
keymap("n", "<C-c>", function()
  Snacks.bufdelete()
end, opts)
keymap("n", "<C-f>", function()
  Snacks.picker.files({ hidden = true })
end, opts)
keymap("n", "<C-b>", function()
  Snacks.picker.buffers()
end, opts)
keymap("n", "<C-g>", function()
  Snacks.picker.grep_buffers()
end, opts)
keymap("n", "<Leader>g", function()
  Snacks.picker.grep()
end, opts)
keymap("n", "<Leader><Leader>", function()
  Snacks.picker.recent()
end, opts)
keymap("n", "<Leader>h", function()
  Snacks.picker.notifications()
end, opts)
keymap("n", "<LocalLeader>gb", function()
  Snacks.gitbrowse()
end, opts)
keymap("n", "<LocalLeader>u", function()
  Snacks.picker.undo()
end, opts)
keymap("n", "<Leader>l", function()
  Snacks.lazygit()
end, opts)

-- Oil
keymap("n", "_", function()
  require("oil").open_float(vim.fn.getcwd())
end, opts)
keymap("n", "-", function()
  require("oil").open_float()
end, opts)

-- Overseer
keymap("n", "<LocalLeader>r", "<cmd>OverseerRun<cr>", opts)

-- Aerial
keymap("n", "<C-t>", function()
  require("aerial").snacks_picker({
    layout = {
      preset = "dropdown",
      preview = false,
    },
  })
end, opts)

-- Multiple Cursors
-- http://www.kevinli.co/posts/2017-01-19-multiple-cursors-in-500-bytes-of-vimscript/
-- https://github.com/akinsho/dotfiles/blob/45c4c17084d0aa572e52cc177ac5b9d6db1585ae/.config/nvim/plugin/mappings.lua#L298

vim.g.mc = vim.api.nvim_replace_termcodes([[y/\V<C-r>=escape(@", '/')<CR><CR>]], true, true, true)

function SetupMultipleCursors()
  keymap(
    "n",
    "<Enter>",
    [[:nnoremap <lt>Enter> n@z<CR>q:<C-u>let @z=strpart(@z,0,strlen(@z)-1)<CR>n@z]],
    { remap = true, silent = true }
  )
end

-- 1. Position the cursor anywhere in the word you wish to change;
-- 2. Or, visually make a selection;
-- 3. Hit cn, type the new word, then go back to Normal mode;
-- 4. Hit `.` n-1 times, where n is the number of replacements.
keymap("n", "cn", "*``cgn", { desc = "Initiate multiple cursors" })
keymap("x", "cn", [[g:mc . "``cgn"]], { expr = true, desc = "Initiate multiple cursors" })
keymap("n", "cN", "*``cgN", { desc = "Initiate multiple cursors (backwards)" })
keymap("x", "cN", [[g:mc . "``cgN"]], { expr = true, desc = "Initiate multiple cursors (backwards)" })

-- 1. Position the cursor over a word; alternatively, make a selection.
-- 2. Hit cq to start recording the macro.
-- 3. Once you are done with the macro, go back to normal mode.
-- 4. Hit Enter to repeat the macro over search matches.
keymap(
  "n",
  "cq",
  [[:\<C-u>call v:lua.SetupMultipleCursors()<CR>*``qz]],
  { desc = "Initiate multiple cursors with macros" }
)
keymap(
  "x",
  "cq",
  [[":\<C-u>call v:lua.SetupMultipleCursors()<CR>gv" . g:mc . "``qz"]],
  { expr = true, desc = "Initiate multiple cursors with macros" }
)
keymap(
  "n",
  "cQ",
  [[:\<C-u>call v:lua.SetupMultipleCursors()<CR>#``qz]],
  { desc = "Initiate multiple cursors with macros (backwards)" }
)
keymap(
  "x",
  "cQ",
  [[":\<C-u>call v:lua.SetupMultipleCursors()<CR>gv" . substitute(g:mc, '/', '?', 'g') . "``qz"]],
  { expr = true, desc = "Initiate multiple cursors with macros (backwards)" }
)

--[[
  Marks / Bookmarks / Harpoon Replacement in c.60 LOC
  Uses m{1-9} to set marks in a file and then '{1-9} to jump to them

  This is the combination of some awesome work over at:
  https://github.com/neovim/neovim/discussions/33335

  I then borrowed some simplification ideas from:
  https://github.com/LJFRIESE/nvim/blob/master/lua/config/autocmds.lua#L196-L340
--]]

-- Convert a mark number (1-9) to its corresponding character (A-I)
local function mark2char(mark)
  if mark:match("[1-9]") then
    return string.char(mark + 64)
  end
  return mark
end

-- List bookmarks in the session
local function list_marks()
  local snacks = require("snacks")
  return snacks.picker.marks({
    transform = function(item)
      if item.label and item.label:match("^[A-I]$") and item then
        item.label = "" .. string.byte(item.label) - string.byte("A") + 1 .. ""
        return item
      end
      return false
    end,
  })
end

-- Add Marks ------------------------------------------------------------------
keymap("n", "m", function()
  local mark = vim.fn.getcharstr()
  local char = mark2char(mark)
  vim.cmd("mark " .. char)
  if mark:match("[1-9]") then
    vim.notify("Added mark " .. mark, vim.log.levels.INFO, { title = "Marks" })
  else
    vim.fn.feedkeys("m" .. mark, "n")
  end
end, { desc = "Add mark" })

-- Go To Marks ----------------------------------------------------------------
keymap("n", "'", function()
  local mark = vim.fn.getcharstr()
  local char = mark2char(mark)
  local mark_pos = vim.api.nvim_get_mark(char, {})
  if mark_pos[1] == 0 then
    return vim.notify("No mark at " .. mark, vim.log.levels.WARN, { title = "Marks" })
  end

  vim.fn.feedkeys("'" .. mark2char(mark), "n")
end, { desc = "Go to mark" })

-- List Marks -----------------------------------------------------------------
keymap("n", "<Leader>mm", function()
  list_marks()
end, { desc = "List marks" })

-- Delete Marks ---------------------------------------------------------------
keymap("n", "<Leader>md", function()
  local mark = vim.fn.getcharstr()
  vim.api.nvim_del_mark(mark2char(mark))
  vim.notify("Deleted mark " .. mark, vim.log.levels.INFO, { title = "Marks" })
end, { desc = "Delete mark" })

keymap("n", "<Leader>mD", function()
  vim.cmd("delmarks A-I")
  vim.notify("Deleted all marks", vim.log.levels.INFO, { title = "Marks" })
end, { desc = "Delete all marks" })
