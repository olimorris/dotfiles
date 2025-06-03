--[[
  Some notes on how I structure my keymaps within Neovim:
    * All keymaps from across my configuration live in this file
    * The general structure of my keymaps are:
        1) Ctrl - Used for your most frequent and easy to remember keymaps
        2) Local Leader - Used for commands related to window or filetype/buffer options
        3) Leader - Used for commands that are global or span Neovim

  N.B. Leader keys are set in the options.lua file. This is so that lazy.nvim doesn't corrupt mappings
]]

-- Functions for multiple cursors
vim.g.mc = vim.api.nvim_replace_termcodes([[y/\V<C-r>=escape(@", '/')<CR><CR>]], true, true, true)

function SetupMultipleCursors()
  vim.keymap.set(
    "n",
    "<Enter>",
    [[:nnoremap <lt>Enter> n@z<CR>q:<C-u>let @z=strpart(@z,0,strlen(@z)-1)<CR>n@z]],
    { remap = true, silent = true }
  )
end

local keymaps = {
  {
    "<C-q>",
    "<cmd>q<CR>",
    mode = "n",
    opts = { remap = true, silent = true, desc = "Quit neovim" },
  },
  { "<C-y>", "<cmd>%y+<CR>", mode = "n", opts = { desc = "Copy buffer" } },
  {
    "<C-s>",
    "<cmd>silent write<CR>",
    mode = "n",
    opts = { desc = "Save buffer" },
  },
  {
    "<C-s>",
    "<cmd>silent write<CR>",
    mode = "i",
    opts = { desc = "Save buffer" },
  },

  { "<Tab>", "<cmd>bnext<CR>", mode = "n", opts = { noremap = false, desc = "Next buffer" } },
  { "<S-Tab>", "<cmd>bprev<CR>", mode = "n", opts = { noremap = false, desc = "Previous buffer" } },

  -- Editing words
  { "<LocalLeader>,", "<cmd>norm A,<CR>", mode = "n", opts = { desc = "Append comma" } },
  { "<LocalLeader>;", "<cmd>norm A;<CR>", mode = "n", opts = { desc = "Append semicolon" } },

  -- Wrap text
  {
    "<LocalLeader>(",
    [[ciw(<c-r>")<esc>]],
    mode = "n",
    opts = { desc = "Wrap text in brackets ()" },
  },
  {
    "<LocalLeader>(",
    [[c(<c-r>")<esc>]],
    mode = "v",
    opts = { desc = "Wrap text in brackets ()" },
  },
  {
    "<LocalLeader>[",
    [[ciw[<c-r>"]<esc>]],
    mode = "n",
    opts = { desc = "Wrap text in square braces []" },
  },
  {
    "<LocalLeader>[",
    [[c[<c-r>"]<esc>]],
    mode = "v",
    opts = { desc = "Wrap text in square braces []" },
  },
  {
    "<LocalLeader>{",
    [[ciw{<c-r>"}<esc>]],
    mode = "n",
    opts = { desc = "Wrap text in curly braces {}" },
  },
  {
    "<LocalLeader>{",
    [[c{<c-r>"}<esc>]],
    mode = "v",
    opts = { desc = "Wrap text in curly braces {}" },
  },
  {
    '<LocalLeader>"',
    [[ciw"<c-r>""<esc>]],
    mode = "n",
    opts = { desc = 'Wrap text in quotes ""' },
  },
  {
    '<LocalLeader>"',
    [[c"<c-r>""<esc>]],
    mode = "v",
    opts = { desc = 'Wrap text in quotes ""' },
  },

  -- Find and replace
  {
    "<LocalLeader>fw",
    [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]],
    mode = "n",
    opts = { desc = "Replace cursor words in buffer" },
  },
  {
    "<LocalLeader>fl",
    [[:s/\<<C-r>=expand("<cword>")<CR>\>/]],
    mode = "n",
    opts = { desc = "Replace cursor words in line" },
  },

  -- Working with lines
  { "B", "^", mode = "n", opts = { desc = "Beginning of a line" } },
  { "B", "^", mode = "v", opts = { desc = "Beginning of a line" } },
  { "E", "$", mode = "n", opts = { desc = "End of a line" } },
  { "E", "$", mode = "v", opts = { desc = "End of a line" } },
  { "<CR>", "o<Esc>", mode = "n", opts = { desc = "Insert blank line below" } },
  { "<S-CR>", "O<Esc>", mode = "n", opts = { desc = "Insert blank line above" } },

  -- Moving lines
  {
    "<A-k>",
    ":m .-2<CR>==",
    mode = "n",
    opts = { silent = true, desc = "Move selection up" },
  },
  {
    "<A-k>",
    ":m '<-2<CR>gv=gv",
    mode = "v",
    opts = { silent = true, desc = "Move selection up" },
  },
  {
    "<A-j>",
    ":m .+1<CR>==",
    mode = "n",
    opts = { silent = true, desc = "Move selection down" },
  },
  {
    "<A-j>",
    ":m '>+1<CR>gv=gv",
    mode = "v",
    opts = { silent = true, desc = "Move selection down" },
  },

  -- Splits
  { "<LocalLeader>sv", "<cmd>vsplit<CR>", mode = "n", opts = { desc = "Split: Create Vertical" } },
  { "<LocalLeader>sh", "<cmd>split<CR>", mode = "n", opts = { desc = "Split: Create Horizontal" } },
  { "<LocalLeader>sc", "<cmd>wincmd q<CR>", mode = "n", opts = { desc = "Split: Close" } },
  { "<LocalLeader>so", "<cmd>wincmd o<CR>", mode = "n", opts = { desc = "Split: Close all but current" } },
  { "<C-k>", "<cmd>wincmd k<CR>", mode = "n", opts = { desc = "Split: Move up" } },
  { "<C-j>", "<cmd>wincmd j<CR>", mode = "n", opts = { desc = "Split: Move down" } },
  { "<C-h>", "<cmd>wincmd h<CR>", mode = "n", opts = { desc = "Split: Move left" } },
  { "<C-l>", "<cmd>wincmd l<CR>", mode = "n", opts = { desc = "Split: Move right" } },

  -- Surrounds
  { "(", "S)", mode = "x", opts = { remap = true, desc = "Surround with ()'s" } },
  { ")", "S)", mode = "x", opts = { remap = true, desc = "Surround with ()'s" } },
  { "{", "S}", mode = "x", opts = { remap = true, desc = "Surround with {}'s" } },
  { "}", "S}", mode = "x", opts = { remap = true, desc = "Surround with {}'s" } },
  { "[", "S]", mode = "x", opts = { remap = true, desc = "Surround with []'s" } },
  { "]", "S]", mode = "x", opts = { remap = true, desc = "Surround with []'s" } },

  -- Misc
  { "<Esc>", "<cmd>:noh<CR>", mode = "n", opts = { desc = "Clear searches" } },
  { "<S-w>", "<cmd>set winbar=<CR>", mode = "n", opts = { desc = "Hide WinBar" } },
  { "<LocalLeader>U", "gUiw`", mode = "n", opts = { desc = "Capitalize word" } },
  { ">", ">gv", mode = "v", opts = { desc = "Indent" } },
  { "<", "<gv", mode = "v", opts = { desc = "Outdent" } },

  -- Multiple Cursors
  -- http://www.kevinli.co/posts/2017-01-19-multiple-cursors-in-500-bytes-of-vimscript/
  -- https://github.com/akinsho/dotfiles/blob/45c4c17084d0aa572e52cc177ac5b9d6db1585ae/.config/nvim/plugin/mappings.lua#L298

  -- 1. Position the cursor anywhere in the word you wish to change;
  -- 2. Or, visually make a selection;
  -- 3. Hit cn, type the new word, then go back to Normal mode;
  -- 4. Hit `.` n-1 times, where n is the number of replacements.
  {
    "cn",
    "*``cgn",
    mode = "n",
    opts = { desc = "Initiate multiple cursors" },
  },
  {
    "cn",
    [[g:mc . "``cgn"]],
    mode = "x",
    opts = { expr = true, desc = "Initiate multiple cursors" },
  },
  {
    "cN",
    "*``cgN",
    mode = "n",
    opts = { desc = "Initiate multiple cursors (backwards)" },
  },
  {
    "cN",
    [[g:mc . "``cgN"]],
    mode = "x",
    opts = { expr = true, desc = "Initiate multiple cursors (backwards)" },
  },

  -- 1. Position the cursor over a word; alternatively, make a selection.
  -- 2. Hit cq to start recording the macro.
  -- 3. Once you are done with the macro, go back to normal mode.
  -- 4. Hit Enter to repeat the macro over search matches.
  {
    "cq",
    [[:\<C-u>call v:lua.SetupMultipleCursors()<CR>*``qz]],
    mode = "n",
    opts = { desc = "Initiate multiple cursors with macros" },
  },
  {
    "cq",
    [[":\<C-u>call v:lua.SetupMultipleCursors()<CR>gv" . g:mc . "``qz"]],
    mode = "x",
    opts = { expr = true, desc = "Initiate multiple cursors with macros" },
  },
  {
    "cQ",
    [[:\<C-u>call v:lua.SetupMultipleCursors()<CR>#``qz]],
    mode = "n",
    opts = { desc = "Initiate multiple cursors with macros (backwards)" },
  },
  {
    "cQ",
    [[":\<C-u>call v:lua.SetupMultipleCursors()<CR>gv" . substitute(g:mc, '/', '?', 'g') . "``qz"]],
    mode = "x",
    opts = { expr = true, desc = "Initiate multiple cursors with macros (backwards)" },
  },
}

for _, keymap in ipairs(keymaps) do
  om.set_keymaps(keymap[1], keymap[2], keymap.mode or "n", keymap.opts)
end
