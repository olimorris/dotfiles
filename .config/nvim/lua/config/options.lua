-- Documentation: https://neovim.io/doc/user/options.html

local vg = vim.g
local vb = vim.bo
local vw = vim.wo
local vo = vim.opt

-- Global variables
Homedir = os.getenv("HOME")
Sessiondir = vim.fn.stdpath("data") .. "/sessions"

-- Global options
vg.mapleader = " " -- space is the leader!
vg.maplocalleader = "\\"

vg.neoterm_autoinsert = 0 -- Do not start terminal in insert mode
vg.neoterm_autoscroll = 1 -- Autoscroll the terminal
vg.loaded_perl_provider = 0 -- Do not load Perl
-- if vim.fn.filereadable(os.getenv("HOME_DIR") .. ".asdf/shims/python2") then
--   vg.python_host_prog = os.getenv("HOME_DIR") .. ".asdf/shims/python2"
-- end
-- if vim.fn.filereadable(os.getenv("HOME_DIR") .. ".local/share/mise/installs/python/3.11.0/bin/python") then
--   vg.python3_host_prog = os.getenv("HOME_DIR") .. ".local/share/mise/installs/python/3.11.0/bin/python"
-- end

-- Buffer options
vb.autoindent = true
vb.expandtab = true -- Use spaces instead of tabs
vb.shiftwidth = 4 -- Size of an indent
vb.smartindent = true -- Insert indents automatically
vb.softtabstop = 4 -- Number of spaces tabs count for
vb.tabstop = 4 -- Number of spaces in a tab
-- vb.wrapmargin = 1

-- Vim options
vo.cmdheight = 0 -- Hide the command bar
vim.schedule(function()
  vo.clipboard = "unnamedplus" -- Use the system clipboard
end)
vo.completeopt = { "menuone", "noselect" } -- Completion opions for code completion
vo.cursorlineopt = "screenline,number" -- Highlight the screen line of the cursor with CursorLine and the line number with CursorLineNr
vo.emoji = false -- Turn off emojis
vo.fillchars = {
  fold = " ",
  foldopen = "",
  foldclose = "",
  foldsep = " ",
  diff = " ",
  eob = " ",
}

vo.foldcolumn = "1" -- Show the fold column
vo.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vo.foldlevelstart = 99
vo.foldenable = true

vo.ignorecase = true -- Ignore case
vo.laststatus = 3 -- Use global statusline

-- Sets how Neovim will display certain whitespace characters in the editor
vo.list = true
vo.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vo.modelines = 1 -- Only use folding settings for this file
vo.mouse = "a" -- Use the mouse in all modes
vo.sessionoptions = { "buffers", "curdir", "folds", "resize", "tabpages", "winpos", "winsize" } -- Session options to store in the session
vo.scrolloff = 5 -- Set the cursor 5 lines down instead of directly at the top of the file
--[[
  ShDa (viminfo for vim): session data history
  --------------------------------------------
  ! - Save and restore global variables (their names should be without lowercase letter).
  ' - Specify the maximum number of marked files remembered. It also saves the jump list and the change list.
  < - Maximum of lines saved for each register. All the lines are saved if this is not included, <0 to disable pessistent registers.
  % - Save and restore the buffer list. You can specify the maximum number of buffer stored with a number.
  / or : - Number of search patterns and entries from the command-line history saved. o.history is used if it’s not specified.
  f - Store file (uppercase) marks, use 'f0' to disable.
  s - Specify the maximum size of an item’s content in KiB (kilobyte).
      For the viminfo file, it only applies to register.
      For the shada file, it applies to all items except for the buffer list and header.
  h - Disable the effect of 'hlsearch' when loading the shada file.

  :oldfiles - all files with a mark in the shada file
  :rshada   - read the shada file (:rviminfo for vim)
  :wshada   - write the shada file (:wrviminfo for vim)
]]
vo.shada = [[!,'100,<0,f100,s100,h]]

vo.shell = "/opt/homebrew/bin/fish"
vo.shiftround = true -- Round indent
vo.shortmess = {
  A = true, -- ignore annoying swap file messages
  c = true, -- Do not show completion messages in command line
  F = true, -- Do not show file info when editing a file, in the command line
  I = true, -- Do not show the intro message
  W = true, -- Do not show "written" in command line when writing
}
-- vo.showcmd = true -- Do not show me what I'm typing
vo.showmatch = true -- Show matching brackets by flickering
vo.showmode = false -- Do not show the mode
vo.sidescrolloff = 8 -- The minimal number of columns to keep to the left and to the right of the cursor if 'nowrap' is set
vo.smartcase = true -- Don't ignore case with capitals
vo.smoothscroll = true -- Smoother scrolling
vo.splitbelow = true -- Put new windows below current
vo.splitright = true -- Put new windows right of current
vo.termguicolors = true -- True color support
vo.textwidth = 120 -- Total allowed width on the screen
vo.timeoutlen = 300 -- Time in milliseconds to wait for a mapped sequence to complete
vo.updatetime = 250 -- If in this many milliseconds nothing is typed, the swap file will be written to disk
vo.wildmode = "list:longest" -- Command-line completion mode
vo.wildignore = { "*/.git/*", "*/node_modules/*" } -- Ignore these files/folders

-- Create folders for our backups, undos, swaps and sessions if they don't exist
vim.schedule(function()
  vim.cmd("silent call mkdir(stdpath('data').'/backups', 'p', '0700')")
  vim.cmd("silent call mkdir(stdpath('data').'/undos', 'p', '0700')")
  vim.cmd("silent call mkdir(stdpath('data').'/swaps', 'p', '0700')")
  vim.cmd("silent call mkdir(stdpath('data').'/sessions', 'p', '0700')")

  vo.backupdir = vim.fn.stdpath("data") .. "/backups" -- Use backup files
  vo.directory = vim.fn.stdpath("data") .. "/swaps" -- Use Swap files
  vo.undodir = vim.fn.stdpath("data") .. "/undos" -- Set the undo directory
end)

vo.undofile = true -- Maintain undo history between sessions
vo.undolevels = 1000 -- Ensure we can undo a lot!

-- Window options
vw.colorcolumn = "80,120" -- Make a ruler at 80px and 120px
vw.list = true -- Show some invisible characters like tabs etc
vw.numberwidth = 2 -- Make the line number column thinner
---Note: Setting number and relative number gives you hybrid mode
---https://jeffkreeftmeijer.com/vim-number/
vw.number = true -- Set the absolute number
vw.relativenumber = true -- Set the relative number
vw.signcolumn = "yes" -- Show information next to the line numbers
vw.wrap = false -- Do not display text over multiple lines
