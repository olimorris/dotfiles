--[[
  Some notes on how I structure my keymaps within Neovim:
    * All keymaps from across my configuration live in this file
    * The general structure of my keymaps are:
        1) Ctrl - Used for your most frequent and easy to remember keymaps
        2) Local Leader - Used for commands related to window or filetype/buffer options
        3) Leader - Used for commands that are global or span Neovim
    * I use legendary.nvim to set all of my mapping and display them in a floating window

  N.B. Leader keys are set in the options.lua file. This is so that lazy.nvim doesn't corrupt mappings
]]

local ok, legendary = pcall(require, "legendary")
if not ok then return end

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

return legendary.keymaps({
  {
    "<C-x>",
    function() om.float_term(nil, { cwd = nil, esc_esc = true }) end,
    description = "Open terminal",
    mode = { "n", "t" },
  },
  { "<C-y>", "<cmd>%y+<CR>", hide = true, description = "Copy buffer" },
  {
    "<C-s>",
    "<cmd>silent! write<CR>",
    hide = true,
    description = "Save buffer",
    mode = { "n", "i" },
  },

  -- Editing words
  { "<LocalLeader>,", "<cmd>norm A,<CR>", hide = true, description = "Append comma" },
  { "<LocalLeader>;", "<cmd>norm A;<CR>", hide = true, description = "Append semicolon" },

  {
    itemgroup = "Wrap text",
    icon = "",
    description = "Wrapping text functionality",
    keymaps = {
      {
        "<LocalLeader>(",
        { n = [[ciw(<c-r>")<esc>]], v = [[c(<c-r>")<esc>]] },
        description = "Wrap text in brackets ()",
      },
      {
        "<LocalLeader>[",
        { n = [[ciw[<c-r>"]<esc>]], v = [[c[<c-r>"]<esc>]] },
        description = "Wrap text in square braces []",
      },
      {
        "<LocalLeader>{",
        { n = [[ciw{<c-r>"}<esc>]], v = [[c{<c-r>"}<esc>]] },
        description = "Wrap text in curly braces {}",
      },
      {
        '<LocalLeader>"',
        { n = [[ciw"<c-r>""<esc>]], v = [[c"<c-r>""<esc>]] },
        description = 'Wrap text in quotes ""',
      },
    },
  },

  {
    itemgroup = "Find and Replace",
    icon = "",
    description = "Find and replace within the buffer",
    keymaps = {
      {
        "<LocalLeader>fw",
        [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]],
        description = "Replace cursor words in buffer",
      },
      { "<LocalLeader>fl", [[:s/\<<C-r>=expand("<cword>")<CR>\>/]], description = "Replace cursor words in line" },
      -- {
      --   "<LocalLeader>f",
      --   ":s/{search}/{replace}/g",
      --   description = "Find and Replace (buffer)",
      --   mode = { "n", "v" },
      --   opts = { silent = false },
      -- },
    },
  },

  -- Working with lines
  { "B", "^", hide = true, description = "Beginning of a line", mode = { "n", "v" } },
  { "E", "$", hide = true, description = "End of a line", mode = { "n", "v" } },
  { "<CR>", "o<Esc>", hide = true, description = "Insert blank line below" },
  { "<S-CR>", "O<Esc>", hide = true, description = "Insert blank line above" },

  -- Moving lines
  {
    "<A-k>",
    {
      n = ":m .-2<CR>==",
      v = ":m '<-2<CR>gv=gv",
    },
    hide = true,
    description = "Move selection up",
    opts = { silent = true },
  },
  {
    "<A-j>",
    hide = true,
    {
      n = ":m .+1<CR>==",
      v = ":m '>+1<CR>gv=gv",
    },
    description = "Move selection down",
    opts = { silent = true },
  },

  -- Splits
  { "<LocalLeader>sv", "<cmd>vsplit<CR>", description = "Split: Vertical" },
  { "<LocalLeader>sh", "<cmd>split<CR>", description = "Split: Horizontal" },
  { "<LocalLeader>sc", "<C-w>q", description = "Split: Close" },
  { "<LocalLeader>so", "<C-w>o", description = "Split: Close all but current" },

  -- Misc
  { "<Esc>", "<cmd>:noh<CR>", description = "Clear searches" },
  { "<S-w>", "<cmd>set winbar=<CR>", description = "Hide WinBar" },
  { "<LocalLeader>U", "gUiw`", description = "Capitalize word" },
  { ">", ">gv", hide = true, description = "Indent", mode = { "v" } },
  { "<", "<gv", hide = true, description = "Outdent", mode = { "v" } },

  -- Multiple Cursors
  -- http://www.kevinli.co/posts/2017-01-19-multiple-cursors-in-500-bytes-of-vimscript/
  -- https://github.com/akinsho/dotfiles/blob/45c4c17084d0aa572e52cc177ac5b9d6db1585ae/.config/nvim/plugin/mappings.lua#L298

  -- 1. Position the cursor anywhere in the word you wish to change;
  -- 2. Or, visually make a selection;
  -- 3. Hit cn, type the new word, then go back to Normal mode;
  -- 4. Hit `.` n-1 times, where n is the number of replacements.
  {
    itemgroup = "Multiple Cursors",
    icon = "",
    description = "Working with multiple cursors",
    keymaps = {
      {
        "cn",
        {
          n = { "*``cgn" },
          x = { [[g:mc . "``cgn"]], opts = { expr = true } },
        },
        description = "Inititiate",
      },
      {
        "cN",
        {
          n = { "*``cgN" },
          x = { [[g:mc . "``cgN"]], opts = { expr = true } },
        },
        description = "Inititiate (in backwards direction)",
      },

      -- 1. Position the cursor over a word; alternatively, make a selection.
      -- 2. Hit cq to start recording the macro.
      -- 3. Once you are done with the macro, go back to normal mode.
      -- 4. Hit Enter to repeat the macro over search matches.
      {
        "cq",
        {
          n = { [[:\<C-u>call v:lua.SetupMultipleCursors()<CR>*``qz]] },
          x = { [[":\<C-u>call v:lua.SetupMultipleCursors()<CR>gv" . g:mc . "``qz"]], opts = { expr = true } },
        },
        description = "Inititiate with macros",
      },
      {
        "cQ",
        {
          n = { [[:\<C-u>call v:lua.SetupMultipleCursors()<CR>#``qz]] },
          x = {
            [[":\<C-u>call v:lua.SetupMultipleCursors()<CR>gv" . substitute(g:mc, '/', '?', 'g') . "``qz"]],
            opts = { expr = true },
          },
        },
        description = "Inititiate with macros (in backwards direction)",
      },
    },
  },
})
